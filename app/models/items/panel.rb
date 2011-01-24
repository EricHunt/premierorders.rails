require 'property.rb'
require 'items/item_materials.rb'

class Panel < Item
  include ItemMaterials

  MATERIAL = PropertyDescriptor.new(:panel_material, [], [Property::Material])

  def self.required_properties
    [MATERIAL]
  end

  WIDTH  = PropertyDescriptor.new(:width, [], [Property::Width], 1)
  LENGTH = PropertyDescriptor.new(:length, [], [Property::Length], 1)

  def self.optional_properties
    super + [WIDTH, LENGTH]
  end

  def width 
    properties.find_value(WIDTH).map{|v| v.width}
  end

  def length
    properties.find_value(LENGTH).map{|v| v.length}
  end

  def material_descriptor
    MATERIAL
  end

  def cost_expr(units, color, contexts, l_expr = L, w_expr = W)
    material_cost = material(MATERIAL, color).cost_expr(
      length.map{|l| term(l)}.orSome(l_expr), 
      width.map{|w| term(w)}.orSome(w_expr), 
      units
    )

    item_total = apply_margin(material_cost)

    super(units, color, contexts).map{|e| sum(e, item_total)}.orElse(Option.some(item_total))
  end
end