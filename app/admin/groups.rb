ActiveAdmin.register Group do

  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      Group.friendly.find(params[:id])
    end

    def collection
      super.includes(:group_request)
    end
  end

  actions :index, :show, :edit, :update


  filter :name
  filter :description
  filter :memberships_count
  filter :created_at
  filter :subdomain
  filter :analytics_enabled

  scope :parents_only
  scope :engaged
  scope :engaged_but_stopped
  scope :has_members_but_never_engaged

  batch_action :delete_spam do |group_ids|
    group_ids.each do |group_id|
      if Group.exists?(group_id)
        group = Group.find(group_id)
        user = group.creator || group.admins.first
        if user
          UserService.delete_spam(user)
        end
      end

      if Group.exists?(group_id)
        Group.find(group_id).destroy
      end
    end

    redirect_to admin_groups_path, notice: "#{group_ids.size} spammy groups deleted"
  end

  index :download_links => false do
    selectable_column
    column :id
    column :name do |g|
      simple_format(g.full_name.sub(' - ', "\n \n> "))
    end
    column :contact do |g|
      admin_name = ERB::Util.h(g.requestor_name)
      admin_email = ERB::Util.h(g.requestor_email)
      simple_format "#{admin_name} \n &lt;#{admin_email}&gt;"
    end

    column "Size", :memberships_count

    column "Discussions", :discussions_count
    column "Motions", :motions_count
    column :created_at
    column :description, :sortable => :description do |group|
      group.description
    end
    column :archived_at
    column :analytics_enabled
    column :enable_experiments
    # TODO: This is a plugin-specific hack. Activeadmin does not take well to being customized.
    # I would rather leave this now and revisit when/if we upgrade our admin panel for more general use.
    if Plugins.const_defined?("LoomioBuyerExperience")
      column("Subscription") { |group| group.subscription&.kind }
    end
    actions
  end

  show do |group|
    attributes_table do
      if Plugins.const_defined?("LoomioBuyerExperience")
        row :standard_plan_link do link_to("standard subscription link", ChargifyService.standard_plan_url(group), target: '_blank' ) end
        row :plus_plan_link do link_to("plus subscription link", ChargifyService.plus_plan_url(group), target: '_blank') end
        row :stats_report_link do link_to("Metabase!", "https://metabase.loomio.io/dash/14?parent_group_id=" + group.id.to_s, target: '_blank') end
        row('Subscription status') do |group| group.subscription.kind if group.subscription end
      end
      group.attributes.each do |k,v|
        row k, v.inspect
      end
    end

    panel("Group Admins") do
      table_for group.admins.each do |admin|
        column :name
        column :email do |user|
          if user.email == group.admin_email
            simple_format "#{mail_to(user.email,user.email)}"
          else
            mail_to(user.email,user.email)
          end
        end
      end
    end

    panel("Group members") do
      table_for group.members.each do |member|
        column :user_id do |user|
          link_to user.id, admin_user_path(user)
        end
        column :name
        column :email
        column :deactivated_at
      end
    end

    panel("Subgroups") do
      table_for group.subgroups.each do |subgroup|
        column :name do |g|
          link_to g.name, admin_group_path(g)
        end
        column :id
      end
    end

    panel("Pending invitations") do
      table_for group.pending_invitations.each do |invitation|
        column :recipient_email
        column :link do |i|
          invitation_url(i)
        end
      end
    end

    if group.archived_at.nil?
      panel('Archive') do
        link_to 'Archive this group', archive_admin_group_path(group), method: :post, data: {confirm: "Are you sure you wanna archive #{group.name}, pal?"}
      end
    else
      panel('Unarchive') do
        link_to 'Unarchive this group', unarchive_admin_group_path(group), method: :post, data: {confirm: "Are you sure you wanna unarchive #{group.name}, pal?"}
      end
    end

    panel 'Move group' do
      form action: move_admin_group_path(group), method: :post do |f|
        f.label "Parent group id / key"
        f.input name: :parent_id, value: group.parent_id
        f.input type: :submit, value: "Move group"
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs "Details" do
      f.input :id, :input_html => { :disabled => true }
      f.input :name, :input_html => { :disabled => true }
      f.input :description
      f.input :subdomain
      f.input :theme, as: :select, collection: Theme.all
      f.input :max_size
      f.input :is_commercial
      f.input :analytics_enabled
      f.input :enable_experiments
      f.input :category_id, as: :select, collection: Category.all
    end
    f.actions
  end

  collection_action :massey_data, method: :get do
    render json: Group.visible_to_public.pluck(:id, :parent_id, :name, :description)
  end

  member_action :move, method: :post do
    group = Group.friendly.find(params[:id])
    if parent = Group.find_by(key: params[:parent_id]) || Group.find_by(id: params[:parent_id].to_i)
      group.subscription&.destroy if Plugins.const_defined?("LoomioBuyerExperience")
      group.update(parent: parent)
    end
    redirect_to admin_group_path(group)
  end

  member_action :archive, :method => :post do
    group = Group.friendly.find(params[:id])
    group.archive!
    flash[:notice] = "Archived #{group.name}"
    redirect_to [:admin, :groups]
  end

  member_action :unarchive, :method => :post do
    group = Group.friendly.find(params[:id])
    group.unarchive!
    flash[:notice] = "Unarchived #{group.name}"
    redirect_to [:admin, :groups]
  end

  #controller do
    #def set_pagination
      #if params[:pagination].blank?
        #@per_page = 40
      #elsif params[:pagination] == 'false'
        #@per_page = 999999999
      #else
        #@per_page = params[:pagination]
      #end
    #end
  #end
end
