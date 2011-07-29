###
  #
  # manages groups. groups are used to define which item categories a user can see in the catalog_orders
  #
###
class GroupsController < ApplicationController
  load_and_authorize_resource 

  def new
    @item_categories = ItemCategory.order('category asc').all
    @group = Group.new()
    @group.name = "Group#{Group.count+ 1}"
  end
  
  def edit
    @item_categories = ItemCategory.order('category asc').all
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    @group.attributes = params[:group]
    if @group.save
      redirect_to :action => "index"
    else
      render :action => 'edit', :id => @group.id
    end
  end

  def create
    @group = Group.new(params[:group])
    if @group.save
      redirect_to :action => "index"
    else
      render :action => 'new'
    end  
  end
  
  def show
    @group = Group.find params[:id]
  end
  
  def index
    @groups = Group.all
  end

end