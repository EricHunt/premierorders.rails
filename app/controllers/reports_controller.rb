class ReportsController < ApplicationController
  before_filter do
    authorize! :view_reports, :all
  end
  
  def orders_items_info
    @jobs = Job.find(:all, :include => [:job_items, :franchisee], :limit => 10)
    @report_data = {}
    @jobs.each do |job|
      @report_data[job.id] = {:items => [],
                              :name => job.to_s,
                              :placement_date => job.placement_date,
                              :franchisee => job.franchisee.franchise_name,
                              :comment => job.comment
                              }
      job.job_items.each do |job_item|
        @report_data[job.id][:items] << {:item_name => job_item.item_name,
                                     :purchase_part_id => (job_item.item.purchase_part_id rescue ''),
                                     :color => job_item.color,
                                     :quantity => job_item.quantity,
                                     :width => job_item.width,
                                     :height => job_item.height,
                                     :depth => job_item.depth}
      end
    end
    
    respond_to do |format|
      format.html # show.html.erb
      format.csv  {
        
        line_headers = ["Date","Franchisee", "Order Name","Item Name","Purchase Part ID","Color","Quantity","Width","Height","Depth", "Special Instructions"]
        csv_options = {:force_quotes => true, :col_sep => ';'}
        @report = ""
        FasterCSV.generate(@report,csv_options) do |csv|
          csv << line_headers
          @report_data.each_pair do |key, job|
            job[:items].each do |job_item| 
              csv << [
                      job[:placement_date],
                      job[:franchisee],
                      job[:name],
                      job_item[:item_name],
                      job_item[:purchase_part_id],
                      job_item[:color],
                      job_item[:quantity],
                      job_item[:width],
                      job_item[:height],
                      job_item[:depth],
                      job[:comment]
                    ]
            end
          end
        end
        send_data @report, :filename => 'orders_items_info.csv'
        
      }
    end
  end
  
  def sales
    @start_date = params[:start_date]
    @end_date   = params[:end_date]
    @franchisee = Franchisee.find_by_id(params[:franchisee_id])
    @franchisees = Franchisee.order(:franchise_name)

    if @start_date && @end_date 
      @jobs = Job.where(['ship_date >= ? and ship_date <= ?', @start_date, @end_date]) 
      @jobs = @jobs.where(['franchisee_id = ?', @franchisee.id]) if @franchisee

      zero = BigDecimal.new("0.0")
      @report_data = @jobs.inject({}) do |results, job|
        job.job_items.each do |job_item|
          sales_category = job_item.sales_category || 'Other'
          franchisee = job_item.job.franchisee
          results[franchisee] ||= {}
          results[franchisee][sales_category] ||= {
            :manufactured => zero,
            :buyout => zero,
            :bulk_inventory => zero
          }

          if job_item.inventory? 
            results[franchisee][sales_category][:bulk_inventory] += job_item.net_total
          elsif job_item.buyout?
            results[franchisee][sales_category][:buyout]         += job_item.net_total
          else
            results[franchisee][sales_category][:manufactured]   += job_item.net_total
            results[franchisee][sales_category][:bulk_inventory] += job_item.hardware_total
          end
        end

        results
      end
    else
      @report_data = {}
    end
  end
end
