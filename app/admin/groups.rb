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
  filter :payment_plan, as: :select, collection: Group::PAYMENT_PLANS
  filter :memberships_count
  filter :created_at
  filter :privacy

  scope :parents_only
  scope :engaged
  scope :engaged_but_stopped
  scope :has_members_but_never_engaged
  scope :visible_on_explore_front_page

  index :download_links => false do
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
    actions
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

    panel("Subgroups") do
      table_for group.subgroups.each do |subgroup|
        column :name
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

    panel('Archive') do
      link_to 'Archive this group', archive_admin_group_path(group), method: :post, confirm: "Are you sure you wanna archive #{group.name}, pal?"
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
      f.input :payment_plan, :as => :select, :collection => Group::PAYMENT_PLANS
      f.input :category_id, as: :select, collection: Category.all
    end
    f.actions
  end

  member_action :archive, :method => :post do
    group = Group.friendly.find(params[:id])
    group.archive!
    flash[:notice] = "Archived #{group.name}"
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
