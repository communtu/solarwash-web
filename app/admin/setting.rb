ActiveAdmin.register Setting do

  index do
    column :sun
    column :time_to_confirm
    
    default_actions
  end
end