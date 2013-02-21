class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.string :name
      t.integer :device_id
      t.integer :degree
      t.integer :duration_in_min
      t.integer :consumption_in_wh

      t.timestamps
    end
  end
end
