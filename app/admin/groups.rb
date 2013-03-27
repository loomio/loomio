ActiveAdmin.register Group do
  actions :index, :show, :edit
  filter :name
  filter :parent

  index :download_links => false do
    column :id
    column :name
    column :max_size
    column "Members", :memberships_count
    column "Discussions", :discussions_count
    column "Motions", :motions_count
    column :created_at
    column :viewable_by
    column :description, :sortable => :description do |group|
      group.description
    end
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :id, :input_html => { :disabled => true }
      f.input :name, :input_html => { :disabled => true }
      f.input :max_size
    end
    f.buttons
  end

  member_action :update, :method => :put do
    group = Group.find(params[:id])
    group.max_size = params[:group][:max_size]
    group.save
    redirect_to admin_groups_url, :notice => "Group updated"
  end
end
