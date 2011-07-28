class Group < ActiveRecord::Base
  has_many :users
  has_many :item_categories, :through => :group_item_categories
  has_many :group_item_categories
  
  def authed_for?(item_category)
    if item_category.is_a? String
      cats = item_categories.map(&:category)
    elsif item_category.is_a? ItemCategory
      cats = item_categories
    elsif item_category.is_a? Integer
      cats = item_categories.map(&:id)
    end
    cats.include? item_category
  end
  
  def item_category_ids
    item_categories.map(&:id)
  end
  
  def categories
    item_categories.map(&:category)
  end
  
  def name_and_categories
    name + " : " + categories.join(', ') 
  end

end