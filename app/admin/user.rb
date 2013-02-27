ActiveAdmin.register User do

  index do
    column :email
    column :apartmentnumber
    column :name

    default_actions
  end
end
