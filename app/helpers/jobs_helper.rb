require 'fp'

module JobsHelper
  def difference(computed, imported)
    Option.some((computed.round(2) - imported.round(2)).abs).filter do |diff|
      diff / imported > 0.005
    end
  end

  def unit_price_mismatch(job_item)
    job_item.compute_unit_price.bind do |computed_price|
      computed_price.right.toOption.bind do |computed|
        difference(computed, job_item.unit_price)
      end
    end
  end

  def unit_price_class(job_item)
    job_item.compute_unit_price.cata( 
      lambda do |computed_price|
        computed_price.cata(
          lambda do |error| 
            'price_calculation_error'
          end,
          lambda do |computed|
            difference(computed, job_item.unit_price).cata(lambda {|v| 'unit_price_mismatch'}, '')
          end
        )
      end,
      'price_not_computed'
    )
  end

  def action_links(job)
    if can? :manage, job
      [link_to('Edit', edit_job_path(job)), link_to('Cutrite', cutrite_job_path(job))] + 
      Option.iif(can? :destroy, job){ link_to('Delete', job, :confirm => 'Are you sure?', :method => :delete) }.to_a
    else 
      Option.iif(can? :update, job){ link_to('Edit', edit_job_path(job)) }.to_a + 
      Option.iif(can? :destroy, job){ link_to('Delete', job, :confirm => 'Are you sure?', :method => :delete) }.to_a
    end
  end

  def job_status_select(job)
    select_tag(
      "job[#{job.id}][status]", 
      options_for_select(Job::STATUS_OPTIONS.map{|v| [v,v]}, job.status), 
      :class => 'job_status'
    ) 
  end

  def job_ship_method_select(job)
    select_tag(
      "job[#{job.id}][ship_method]", 
      options_for_select(Job::SHIPMENT_OPTIONS.map{|v| [v,v]}, job.ship_method), 
      :class => 'job_ship_method'
    )
  end
end
