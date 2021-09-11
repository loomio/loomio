ActiveAdmin.register Template do
  includes :group
  includes :record
  includes :author

  controller do
    def permitted_params
      params.permit!
    end
  end

  form do |f|
    f.inputs "Details" do
      f.input :author_id
      f.input :group_id
      f.input :record_id
      f.input :record_type
      f.input :name
      f.input :description, as: :text
    end
    f.actions
  end

  actions :index, :show, :new, :edit, :update, :create
end
