class GroupItemCategory < ActiveRecord::Base
  belongs_to :group
  belongs_to :item_category
end