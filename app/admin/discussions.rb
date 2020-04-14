ActiveAdmin.register Group, as: 'Discussion' do

  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      Group.friendly.find(params[:id])
    end
  end

  actions :index, :show, :new, :edit, :update, :create

  filter :title


  index :download_links => false do
    column :id
    column :group do |g|
      g.group.full_name
    end
    column :title

    actions
  end


end
