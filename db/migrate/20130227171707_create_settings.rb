class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.integer :sun_hour
      t.integer :sun_minute
      t.integer :sun_second
      t.integer :time_to_confirm

      t.timestamps
    end
  end
end
