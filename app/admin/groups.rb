ActiveAdmin.register FormalGroup, as: 'Group' do

  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      FormalGroup.friendly.find(params[:id])
    end
  end

  actions :index, :show, :new, :edit, :update, :create

  filter :name
  filter :description
  filter :memberships_count
  filter :created_at
  filter :handle
  filter :analytics_enabled

  scope :parents_only

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
      g.full_name
    end

    column "Members", :memberships_count
    column "Discussions", :discussions_count
    column :created_at
    column :description, :sortable => :description do |group|
      group.description
    end
    column :archived_at
    column :analytics_enabled
    column :enable_experiments
    actions
  end

  show do |group|
    render 'graph', { group: group }
    render 'stats', { group: group }

    if group.subscription_id
      render 'subscription', { subscription: group.subscription }
    end

    panel("Subgroups") do
      table_for group.subgroups.order(memberships_count: :desc).each do |subgroup|
        column :name do |g|
          link_to g.name, admin_group_path(g)
        end
        column :memberships_count
        column :discussions_count
      end
    end

    panel("Members") do
      table_for group.all_memberships.each do
        column(:name)        { |m| link_to m.user.name, admin_user_path(m.user) }
        column(:email)       { |m| m.user.email }
        column(:coordinator) { |m| m.admin }
        column(:invter)      { |m| m.inviter.name }
        column(:accepted_at) { |m| m.accepted_at }
        column(:archived_at) { |m| m.archived_at }
        column "Support" do |m|
          if m.user.name.present?
            link_to("Search for #{m.user.name}", "https://support.loomio.org/scp/users.php?a=search&query=#{m.user.name.downcase.split(' ').join('+')}")
          end
        end
      end
    end

    active_admin_comments

    attributes_table do
      if Plugins.const_defined?("LoomioBuyerExperience")
        row :standard_plan_link do link_to("standard subscription link", ChargifyService.standard_plan_url(group), target: '_blank' ) end
        row :plus_plan_link do link_to("plus subscription link", ChargifyService.plus_plan_url(group), target: '_blank') end
        row :stats_report_link do link_to("Metabase!", "https://metabase.loomio.io/dash/14?parent_group_id=" + group.id.to_s, target: '_blank') end
        row('Subscription status') do |group| group.subscription.kind if group.subscription end
      end

      row :id
      row :name
      row :key
      row :full_name
      row :created_at
      row :updated_at
      row :parent
      row :creator_id
      row :description
      row :archived_at
      row :discussions_count
      row :memberships_count
      row :admin_memberships_count
      row :unverified_memberships_count
      row :public_discussions_count
      row :payment_plan

      row "Group Privacy" do
        if group.is_visible_to_public && group.discussion_privacy_options == 'public_only'
          "Open"
        elsif group.is_visible_to_public && group.discussion_privacy_options != 'public_only'
          "Closed"
        elsif group.is_visible_to_parent_members && !group.is_visible_to_public
          "Closed"
        elsif !group.is_visible_to_parent_members && !group.is_visible_to_public
          "Secret"
        else
          "Group privacy unknown"
        end
      end

      row :is_visible_to_public
      row :discussion_privacy_options
      row :is_visible_to_parent_members
      row :parent_members_can_see_discussions
      row :members_can_add_members
      row :membership_granted_upon
      row :members_can_edit_discussions
      row :members_can_edit_comments
      row :members_can_raise_motions
      row :members_can_vote
      row :members_can_start_discussions
      row :members_can_create_subgroups
      row :handle
      row :is_referral
      row :cohort_id
      row :subscription_id
      row :enable_experiments
      row :analytics_enabled
      row :experiences
      row :features
      row :theme_id
      row :cover_photo_file_name
      row :cover_photo_content_type
      row :cover_photo_updated_at
      row :logo_file_name
      row :logo_content_type
      row :logo_file_size
      row :logo_updated_at
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

    panel 'Set handle / subdomain' do
      form action: handle_admin_group_path(group), method: :post do |f|
        f.label "Handle"
        f.input name: :handle, value: group.handle
        f.input type: :submit, value: "Set handle"
      end
    end

    render 'delete_group', { group: group }
    render 'export_group', { group: group }
  end

  form do |f|
    f.inputs "Details" do
      if f.object.persisted?
        f.input :id, :input_html => { :disabled => true }
      end
      f.input :name, :input_html => { :disabled => f.object.persisted? }
      f.input :admin_tags, label: "Tags (separated by a space)"
      f.input :description, :input_html => { :disabled => true }
      f.input :parent_id, label: "Parent Id"
      f.input :handle, as: :string
      f.input :subscription_id, label: "Subscription Id"
    end
    f.actions
  end

  member_action :move, method: :post do
    group  = Group.friendly.find(params[:id])
    parent = Group.friendly.find(params[:parent_id])
    GroupService.move(group: group, parent: parent, actor: current_user)
    redirect_to admin_group_path(group)
  end

  member_action :handle, method: :post do
    params.permit(:id, :handle)
    group = Group.friendly.find(params[:id])
    group.update(handle: params[:handle])
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

  member_action :delete_group, :method => :post do
    group = Group.friendly.find(params[:id])
    group.delay.destroy!
    redirect_to [:admin, :groups]
  end

  member_action :export_group, method: :post do
    group = Group.friendly.find(params[:id])
    GroupExportJob.perform_later(group_ids: group.all_groups.pluck(:id),
                                 group_name: group.name,
                                 actor: current_user)
    redirect_to admin_group_path(group)
  end
end
