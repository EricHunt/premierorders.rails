require 'util/option'
require 'util/either'

class JobItem < ActiveRecord::Base
	belongs_to :job
  belongs_to :item
	has_many   :job_item_properties, :dependent => :destroy, :extend => Properties::Association

  def dimensions_property 
    @dimensions_property ||= Option.new(job_item_properties.find_by_family(:dimensions))
    @dimensions_property
  end

  def inventory?
    (item && item.purchasing == 'Inventory') || ingest_id.strip[-1,1] == 'I'
  end

  def width
    dimensions_property.bind do |p|
      Option.call(:width, p)
    end
  end

  def height
    dimensions_property.bind do |p|
      Option.call(:height, p)
    end
  end

  def depth
    dimensions_property.bind do |p|
      Option.call(:depth, p)
    end
  end

  def color
    Option.new(job_item_properties.find_by_family(:color)).map{|p| p.color}
  end

  def dvinci_color_code
    ingest_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\w{3})\.(\d{2})(\w)/).captures[3]
  end

  def item_name
    item.nil? ? "#{ingest_desc}: #{ingest_id}" : item.name
  end

  def compute_unit_price
    Option.new(item).bind do |i|
      begin
        i.rebated_cost_expr(:in, color.orSome(nil), []).map {|expr| dimension_eval(expr)}
      rescue
        Option.some(Either.left($!.message))
      end
    end
  end

  def weight
    Option.new(item).bind do |i|
      begin
        i.weight_expr(:in, []).map {|expr| dimension_eval(expr)}
      rescue
        Option.some(Either.left($!.message))
      end
    end
  end

  def install_cost
    Option.new(item).bind do |i|
      begin
        i.install_cost_expr(:in, []).map {|expr| dimension_eval(expr)}
      rescue
        Option.some(Either.left($!.message))
      end
    end
  end

  def dimension_eval(expr)
    w = width.orSome(nil)
    h = height.orSome(nil)
    d = depth.orSome(nil)
    compiled_expr = expr.compile.gsub(/W/,'w').gsub(/H/,'h').gsub(/D/,'d')
    begin
      Either.right(eval(compiled_expr))
    rescue
      logger.error("Unable to evaluate expression (#{compiled_expr}) at w = #{w}, h = #{h}, d = #{d}")
      Either.left("Unable to evaluate expression (#{compiled_expr}) at w = #{w}, h = #{h}, d = #{d}")
    end
  end

  def compute_total
    compute_unit_price.map{|e| e.right.map{|t| t * quantity}}
  end
end
