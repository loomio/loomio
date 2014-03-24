ActiveAdmin.register Group do

  controller do
    def collection
      super.includes(:group_request)
    end
  end

  actions :index, :show, :edit, :update
  before_filter :set_pagination
  filter :name
  filter :payment_plan, as: :select, collection: Group::PAYMENT_PLANS
  filter :memberships_count
  filter :created_at

  scope :parents_only
  scope :engaged
  scope :engaged_but_stopped
  scope :has_members_but_never_engaged
  scope :visible_on_explore_front_page


  csv do
    column :id
    column :name
    column :member_email_addresses do |g|
      g.members.map{|m| [m.name, m.email] }.map{|ne| "#{ne[0]} <#{ne[1]}>"}.join(', ')
    end

    column :admin_email_addresses do |g|
      g.admins.map{|m| [m.name, m.email] }.map{|ne| "#{ne[0]} <#{ne[1]}>"}.join(', ')
    end
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
    column :privacy
    column :description, :sortable => :description do |group|
      group.description
    end
    column :payment_plan
    default_actions
  end

  show do |group|
    attributes_table do
      row :group_request
      group.attributes.each do |k,v|
        row k.to_sym if v.present?
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

    panel("Pending invitations") do
      table_for group.pending_invitations.each do |invitation|
        column :recipient_email
        column :link do |i|
          invitation_url(i)
        end
      end
    end

    panel('Archive') do
      link_to 'Archive this group', archive_admin_group_path(group), method: :post, confirm: "Are you sure you wanna archive #{group.name}, pal?"
    end
    active_admin_comments
  end

  form do |f|
    f.inputs "Details" do
      f.input :id, :input_html => { :disabled => true }
      f.input :name, :input_html => { :disabled => true }
      f.input :max_size
      f.input :payment_plan, :as => :select, :collection => Group::PAYMENT_PLANS
      f.input :category_id, as: :select, collection: Category.all
    end
    f.buttons
  end

  #member_action :update, :method => :put do
    #group = Group.find(params[:id])
    #group.max_size = params[:group][:max_size]
    #group.payment_plan = params[:group][:payment_plan]
    #group
    #if group.save
      #redirect_to admin_groups_url, :notice => "Group updated."
    #else
      #redirect_to admin_groups_url, :notice => "WARNING: Group could not be updated."
    #end
  #end

  member_action :archive, :method => :post do
    group = Group.find(params[:id])
    group.archive!
    flash[:notice] = "Shoved #{group.name} into the filing cabinet that nobody touches"
    redirect_to [:admin, :groups]
  end

  controller do
    def set_pagination
      if params[:pagination].blank?
        @per_page = 40
      elsif params[:pagination] == 'false'
        @per_page = 999999999
      else
        @per_page = params[:pagination]
      end
    end
  end

  config.batch_actions = true

  batch_action :email do |group_ids|
    redirect_to new_admin_email_groups_path(group_ids: group_ids)
  end

  controller do
    def permitted_params
      params.permit!
    end
  end
end
