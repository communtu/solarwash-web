ActiveAdmin.register Device do

  index do
    column :id
    column :name
    column :state
    column :devicetype

    default_actions
  end
end