ActiveAdmin.register ForwardEmailRule do
  filter :handle
  filter :email

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :handle
      f.input :email
    end
    f.actions
  end

  actions :index, :show, :new, :edit, :update, :create
end
