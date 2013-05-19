ActiveAdmin.register ErrorRaincheck do
  index do
    column :id
    column :email
    column :controller
    column :action
    column :created_at

    default_actions
  end
end
