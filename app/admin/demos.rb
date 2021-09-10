ActiveAdmin.register Demo do
  includes :group

  controller do
    def permitted_params
      params.permit!
    end
  end

  actions :index, :show, :new, :edit, :update, :create
end
