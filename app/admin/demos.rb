ActiveAdmin.register Demo do
  includes :group
  includes :author

  filter :name

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :author_id
      f.input :group_id
      f.input :recorded_at
      f.input :name
      f.input :demo_handle
      f.input :priority
      f.input :description, as: :text
    end
    f.actions
  end

  actions :index, :show, :new, :edit, :update, :create
end
