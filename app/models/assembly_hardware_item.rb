require 'fp'

class AssemblyHardwareItem
  attr_reader :item, :quantity, :weight, :install_cost, :total_price

  def initialize(item, quantity = 0, total_price = BigDecimal.new("0.00"))
    @item = item
    @quantity = quantity
    @total_price = total_price
  end

  def add_hardware(job_item, assoc)
    job_item.dimension_eval(assoc.qty_expr(:in)).right.each do |qty|
      @quantity += (qty * job_item.quantity)
    end

    assoc.cost_expr(:in, color.orSome(nil), []).each do |expr| 
      job_item.dimension_eval(expr).right.each do |price|
        @total_price += (price * job_item.quantity)
      end
    end

    self
  end

  def +(other)
    raise "Item mismatch: #{@item} is not equal to #{other.item}" unless @item == other.item
    AssemblyHardwareItem.new(@item, @quantity + other.quantity, @total_price + other.total_price)
  end

  def *(qty)
    @quantity *= qty
    @total_price *= qty
  end

  def tracking_id
    ''
  end

  def item_name
    @item.name
  end

  def color
    #@job_item.color.bind{|c| Option.new(item.color_opts.find{|o| o.color == c})}
    Option.none
  end

  def width
    # The relationships between the dimensions of items need to be factored out of the 
    # pricing expressions to be able to have meaningful values here.
    Option.none
  end

  def height
    Option.none
  end

  def depth
    Option.none
  end

  def compute_unit_price
    Option.iif(@quantity > 0) do
      Either.right(@total_price / @quantity)
    end
  end

  def net_unit_price
    @total_price / @quantity
  end

  alias_method :unit_price, :net_unit_price

  def compute_total
    Option.some(Either.right(@total_price))
  end

  def net_total
    @total_price
  end

  def weight
    Option.new(item.weight).map do |w|
      Either.right(w * @quantity)
    end
  end

  def install_cost
    Option.new(item.install_cost).map do |w|
      Either.right(w * @quantity)
    end
  end

  def comment
    ''
  end
end
