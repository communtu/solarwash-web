ActiveAdmin.register Setting do

  index do
    column :sun_hour
    column :sun_minute
    column :sun_second
    column :time_to_confirm
    
    default_actions
  end
end