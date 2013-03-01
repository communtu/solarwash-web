class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :device_id
      t.integer :user_id
      t.integer :program_id
      t.integer :finished
      t.boolean :confirm
      t.boolean :is_running
      t.datetime :start_of_timespan
      t.datetime :end_of_timespan
      t.datetime :start

      t.timestamps
    end
  end
end
