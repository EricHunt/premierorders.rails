require 'properties'

class Items::CornerCabinetVerticalPanels < ItemComponent
  include Items::CornerCabinetPanelAssociation

  EB_SIDES = [:top, :bottom, :front]

  def self.component_types
    [Items::Panel]
  end

  def self.required_properties
    [CORNER_SIDE_RATIO]
  end

  def self.optional_properties
    [Properties::PropertyDescriptor.new(:edge_band, EB_SIDES, [Property::EdgeBand]), MARGIN]
  end

  def cost_expr(query_context)
    component.cost_expr(query_context, H, side_width_expr).bind do |side_cost|
      component.cost_expr(query_context, H, D).map do |wall_side_cost|
        panel_cost = sum(side_cost, wall_side_cost)
        edgeband_cost = edgeband_cost_expr({:top => side_width_expr, :bottom => side_width_expr, :front => H}, query_context.units, query_context.color)
        subtotal = edgeband_cost.map{|e| sum(panel_cost, e)}.orSome(panel_cost) * term(2) # 2 vertical panels per cabinet

        apply_margin(subtotal)
      end
    end
  end
end

