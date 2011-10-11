class AddCustomerCategory < ActiveRecord::Migration
  def self.up
    add_column :franchisees, :customer_category, :int, :default => 0, :null => false
  end

  def self.down
    remove_column :franchisees, :customer_category
  end
end
