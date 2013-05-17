ActiveAdmin.register Campaign do
  actions :index, :edit, :update

  form do |f|
    f.inputs do
      f.input :name, :input_html => { :disabled => true }
      f.input :showcase_url
      f.input :manager_email
    end
    f.buttons
  end
end
