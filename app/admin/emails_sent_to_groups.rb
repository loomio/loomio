ActiveAdmin.register EmailTemplateSentToGroup do
  index do
    selectable_column
    column :email_template
    column :group
    column :recipients
    column :author
    column :created_at
  end
  controller do
    def permitted_params
      params.permit!
    end
  end
end
