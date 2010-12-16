require 'items/panel.rb'
require 'property.rb'

module ShellPanel
  def self.included(mod)
    def mod.component_types
      [Panel]
    end
  end

  def edge_banding_price(color, side_lengths, units)
    # Find the edge banding property value for each side
    edge_banding = side_lengths.keys.inject({}) do |result, side|
      properties.find_by_family_with_qualifier(:edge_band, side).each do |prop|
        result[side] = prop.property_values.all.find{|v| v.color == color}
      end

      result
    end

    total = 0.0
    side_lengths.each do |side, length|
      total += edge_banding[side].price(length, units) if edge_banding[side]
    end
    total
  end
end

class ShellBackPanel < ItemComponent
  def calculate_price(width, height, depth, color, units )
    quantity * component.calculate_price(height, width, color, units)
  end
end

class ShellHorizontalPanel < ItemComponent
  include ShellPanel

  EB_SIDES = [:left, :right, :rear, :front]

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand])]
  end

  def calculate_price(width, height, depth, color, units)
    edgeband_price = edge_banding_price(
      color,
      {:left => depth, :right => depth, :rear => width, :front => width},
      units
    )

    quantity * (component.calculate_price(width, depth, color, units) + edgeband_price)
  end
end

class ShellVerticalPanel < ItemComponent
  include ShellPanel

  EB_SIDES = [:top, :bottom, :rear, :front]

  def self.optional_properties
    [PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand])]
  end

  def calculate_price(width, height, depth, color, units)
    edgeband_price = edge_banding_price(
      color,
      {:top => depth, :bottom => depth, :rear => height, :front => height},
      units
    )

    quantity * (component.calculate_price(height, depth, color, units) + edgeband_price)
  end
end

