ActiveAdmin.register Theme do
  index do
    column :name
    column :updated_at
    actions
  end

  show do |theme|
    attributes_table do
      row :name
      row :pages_logo do
        image_tag(theme.pages_logo.url)
      end

      row :app_logo do
        image_tag(theme.app_logo.url)
      end

      pre do
        theme.style
      end
    end

    active_admin_comments
  end

  form partial: 'form'


  controller do
    def permitted_params
      params.permit!
    end
  end

end
