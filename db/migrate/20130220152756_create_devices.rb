class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.integer :devicetype
      t.integer :state

      t.timestamps
    end
  end
end
