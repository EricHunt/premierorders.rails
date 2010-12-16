class ItemsController < ApplicationController
  # GET /items
  # GET /items.xml
  def index
    @items = Item.order(:name, :dvinci_id).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @items }
    end
  end

  # GET /items/1
  # GET /items/1.xml
  def show
    @item = Item.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/new
  # GET /items/new.xml
  def new
    @item = Item.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @item }
    end
  end

  # GET /items/1/edit
  def edit
    @item = Item.find(params[:id])
  end

  # POST /items
  # POST /items.xml
  def create
    @item = Item.new(params[:item])

    respond_to do |format|
      if @item.save
        format.html { redirect_to(@item, :notice => 'Item was successfully created.') }
        format.xml  { render :xml => @item, :status => :created, :location => @item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /items/1
  # PUT /items/1.xml
  def update
    @item = Item.find(params[:id])

    if @item && params[:item][:type] 
      Item.execute_sql(["UPDATE items SET type = ? WHERE id = ?", params[:item][:type], @item.id]);
    end

    respond_to do |format|
      if @item.update_attributes(params[:item])
        format.html { redirect_to(@item, :notice => 'Item was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.xml
  def destroy
    @item = Item.find(params[:id])
    @item.destroy

    respond_to do |format|
      format.html { redirect_to(items_url) }
      format.xml  { head :ok }
    end
  end

  def search
    @items = Item.search(params[:types], params[:term])

    if request.xhr?
      render :json => @items.map{|item| item_select_json(item)}
    end
  end

  def item_select_json(item)
    {
      :label => item.name,
      :value => {
        :item_id => item.id,
        :item_name => item.name,
        :item_type => item.class.to_s.demodulize,
        :dvinci_id => item.dvinci_id
      }
    }
  end

  def properties
    if request.xhr?
      item = Item.find(params[:id])
      render :partial => 'properties', :layout => false, :locals => {
        :id => 'item_properties',
        :properties => item.item_properties
      }
    end
  end

  def add_property
    if request.xhr?
      item = Item.find(params[:receiver_id])
      property = Property.find(params[:property_id])
      if (params[:qualifiers] && !params[:qualifiers].empty?)
        params[:qualifiers].each do |idx, q|
          ItemProperty.create(:item => item, :property => property, :qualifier => q)
        end
      else
        ItemProperty.create(:item => item, :property => property)
      end

      render :nothing
    end
  end

  def add_property_form
    render '_add_property', :layout => 'minimal', :locals => {
      :receiver_root => 'items'
    }
  end

  def add_component_form
    render '_add_component', :layout => 'minimal'
  end

  def property_descriptors
    if request.xhr?
      render :json => Property.descriptors(Items.const_get(params[:mod])).to_json
    end
  end

  def property_form_fragment
    descriptor_id = params[:id].to_i
    descriptor = Property.descriptors(Items.const_get(params[:mod]))[descriptor_id]
    logger.info descriptor.inspect

    render :partial => 'property_descriptor', :layout => false, :locals => {
      :descriptor => descriptor,
      :descriptor_id => descriptor_id
    }
  end
  
  def component_types
    if request.xhr?
      render :json => Item.component_modules(Items.const_get(params[:mod])).to_json
    end
  end

  def component_association_types
    logger.info("Looking for module #{params[:mod]}")
    logger.info("Found module #{Items.const_get(params[:mod])}")
    type_map = Item.component_association_modules(Items.const_get(params[:mod])).inject([]) do |result, cmod|
      result << { 
        :association_type => cmod.to_s.demodulize,
        :component_types  => Item.component_modules(cmod).map{|ct| ct.to_s.demodulize} 
      }
    end

    if request.xhr?
      render :json => type_map.to_json
    end
  end
end
