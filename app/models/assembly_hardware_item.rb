class AssemblyHardwareItem
  attr_reader :item, :quantity

  def initialize(item)
    @item = item
    @quantity = 0.0
    @total_price = 0.0
  end

  def add_hardware(job_item, assoc)
    @quantity += job_item.dimension_eval(assoc.qty_expr(:in, color.orSome(nil)))

    assoc.cost_expr(:in, color.orSome(nil), []).each do |expr| 
      @total_price += job_item.dimension_eval(expr)
    end

    self
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
      @total_price / @quantity
    end
  end

  def unit_price
    # This is wrong, but it requires rework of the display to correct it. So this is a hack
    # to allow continued reuse of jobs/_items_table.html.erb
    compute_unit_price.orSome(0.0)
  end

  def compute_total
    Option.some(@total_price)
  end

  def comment
    ''
  end
end