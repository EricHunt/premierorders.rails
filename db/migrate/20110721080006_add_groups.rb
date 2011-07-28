class AddGroups < ActiveRecord::Migration
  def self.up
    
    create_table :group_item_categories do |t|
      t.integer :item_category_id
      t.integer :group_id
    end
    
    create_table :groups do |t|
      t.string :name
    end
    
    add_column :users, :group_id, :int, :default => 1, :null => false

    execute "insert into groups(name) values ('Group1')"
  end

  def self.down
    drop_table :group_item_categories
    drop_table :groups
    remove_column :users, :group_id
  end
end
