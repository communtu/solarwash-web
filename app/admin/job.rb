ActiveAdmin.register Job do

  index do
    column :device_id
    column :program_id
    column :start_of_timespan
    column :end_of_timespan
    column :start
    column :finished
    column :user_id
    column :confirm


    default_actions
  end
end