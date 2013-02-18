class AddDescriptionAndGroupIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :description, :text
    add_column :users, :group_id, :int
  end
end
