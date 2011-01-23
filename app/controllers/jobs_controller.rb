require 'date'
require 'job.rb'

class JobsController < ApplicationController
  load_and_authorize_resource :except => [:new, :create]

  # GET /jobs
  # GET /jobs.xml
  def index
    @jobs = @jobs.order('jobs.created_at DESC NULLS LAST, jobs.due_date DESC NULLS LAST')

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.xml
  def show
    @total = @job.job_items.inject(0.0) do |total, job_item|
      total += job_item.compute_total
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.xml
  def new
    @job = Job.new
    @franchisees = if can? :admin_job, @job
      Franchisee.order(:franchise_name)
    else
      current_user.franchisees.order(:franchise_name)
    end
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @franchisees = Franchisee.find(:all)
    @addresses = @franchisees[0].nil? ? [] : @franchisees[0].addresses
  end

  # POST /jobs
  # POST /jobs.xml
  def create
    begin
      @job = Job.new(params[:job])
      @job.customer = current_user

      respond_to do |format|
        if @job.save
          File.open(@job.dvinci_xml.path) do |f|
            @job.add_items_from_dvinci(f)
          end
          @job.save
          format.html { redirect_to(@job, :notice => 'Job was successfully created.') }
          format.xml  { render :xml => @job, :status => :created, :location => @job }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
        end
      end
    rescue FormatException => ex
      flash[:error] = ex.message
      redirect_to :back
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.xml
  def update
    if request.xhr?
      if @job.update_attributes(params[:job])
        render :json => {:updated => 'success'}
      else
        render :json => {:updated => 'error'}
      end
    else
      respond_to do |format|
        if @job.update_attributes(params[:job])
          format.html { redirect_to(@job, :notice => 'Job was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  def place_order
    @job.place_order(DateTime.now, current_user)
    respond_to do |format|
      if @job.save
        format.html { redirect_to(@job, :notice => 'Order was successfully placed.') }
        format.xml  { head :ok }
      else
        format.html { redirect_to(@job, :error => "Order could not be placed: #{@job.errors}.") }
        format.xml  { render :xml => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  def cutrite
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @cutrite_data }
    end
  end

  def download
    send_data @job.to_cutrite_csv,
      :type => 'text/csv; charset=iso-8859-1; header=present',
      :disposition => "attachment; filename=#{job.job_number}.csv"
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.xml
  def destroy
    @job.destroy

    respond_to do |format|
      format.html { redirect_to(jobs_url) }
      format.xml  { head :ok }
    end
  end
end
