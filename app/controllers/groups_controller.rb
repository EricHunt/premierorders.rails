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
  
  def create
    @group = Group.new(params[:group])
    if @group.save
      render :action => "show"
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