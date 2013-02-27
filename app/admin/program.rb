ActiveAdmin.register Program do

  index do
    column :name
    column :device_id
    column :consumption_in_wh
    column :degree
    column :duration_in_min

    default_actions
  end
end
