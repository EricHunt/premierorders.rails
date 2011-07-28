class ItemCategory < ActiveRecord::Base
  has_many :groups, :through => :group_item_categories
  has_many :group_item_categories
end
