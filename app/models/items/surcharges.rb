require 'expressions'

module Items::Surcharges
  include Expressions
  SURCHARGE = PropertyDescriptor.new(:surcharge, [], [Property::Surcharge])
  RANGED_SURCHARGE = PropertyDescriptor.new(:ranged_surcharge, [], [Property::RangedValue])

  def surcharge_exprs(units)
    flat = properties.find_value(SURCHARGE).map{|v| term(v.price)}.to_a
    ranged = properties.find_all_by_descriptor(RANGED_SURCHARGE).map{|v| v.property_values}.flatten.map{|v| v.expr(units)}

    flat + ranged
  end
end



