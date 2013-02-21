class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :device_id
      t.integer :user_id
      t.integer :program_id
      t.integer :finished
      t.datetime :start_of_timespan
      t.datetime :end_of_timespan

      t.timestamps
    end
  end
end
