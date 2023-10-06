ActiveAdmin.register User do
  actions :index, :show, :edit

  filter :name
  filter :username
  filter :email, as: :string
  filter :email_newsletter
  filter :email_verified
  filter :sign_in_count
  filter :detected_locale, as: :string
  filter :time_zone
  filter :created_at

  scope :all
  scope :coordinators

  csv do
    column :name
    column :email
    column :email_newsletter
    column :locale
    column :time_zone
  end

  controller do
    def permitted_params
      params.permit!
    end

    def find_resource
      User.friendly.find(params[:id])
    end
  end

  index do
    column :name
    column :email
    column :created_at
    column :last_sign_in_at
    column "No. of groups", :memberships_count
    column :deactivated_at
    column :email_verified
    column :locale
    column :time_zone
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :email, as: :string
      f.input :username, as: :string
      f.input :is_admin
    end
    f.actions
  end

  member_action :update, :method => :put do
    user = User.friendly.find(params[:id])
    user.name = params[:user][:name]
    user.email = params[:user][:email]
    user.username = params[:user][:username]
    user.is_admin = params[:user][:is_admin]
    user.save
    redirect_to admin_users_path, :notice => "User updated"
  end

  member_action :login_as, :method => :get do
    @user = User.friendly.find(params[:id])
    @token = @user.login_tokens.create
  end

  member_action :merge, method: :post do
    source = User.friendly.find(params[:id])
    destination = User.find_by!(email: params[:destination_email].strip)
    MigrateUserWorker.perform_async(source.id, destination.id)
    redirect_to admin_user_path(destination)
  end

  member_action :deactivate, method: :put do
    DeactivateUserWorker.perform_async(params[:id])
    redirect_to admin_users_path, :notice => "User scheduled for deactivation immediately"
  end

  member_action :reactivate, method: :put do
    GenericWorker.perform_async('UserService', 'reactivate', params[:id])
    redirect_to admin_users_path, :notice => "User scheduled for reactivation immediately"
  end

  member_action :delete_spam, method: :delete do
    DestroyUserWorker.perform_async(params[:id])
    redirect_to admin_users_path, :notice => "User scheduled for deletion immediately"
  end

  member_action :delete_identity, method: :post do
    User.find(params[:id]).identities.find(params[:identity_id]).destroy
    redirect_to admin_user_path(User.find(params[:id]))
  end

  show do |user|
    attributes_table do
      user.attributes.each do |k,v|
        row k.to_sym
      end
    end

    if user.deactivated_at.nil?
      panel("Deactivate") do
        button_to 'Deactivate User', deactivate_admin_user_path(user), method: :put, data: {confirm: 'Are you sure you want to deactivate this user?'}
      end
    end

    panel("Reactivate") do
      button_to 'Reactivate User', reactivate_admin_user_path(user), method: :put, data: {confirm: 'Are you sure you want to reactivate this user?'}
    end

    panel("Destroy") do
      [
      p("Delete the user and any groups, threads, comments, votes they created. It will not groups or threads they are simply a member of."),
      button_to('Destroy User', delete_spam_admin_user_path(user), method: :delete, data: {confirm: 'Are you sure you want to destroy this user and content they authored?'})
      ].join.html_safe
    end

    panel("Memberships") do
      table_for user.memberships.includes(:group, :user).order(:id).each do |m|
        column :id
        column :group_name do |g|
          group = g.group
          link_to group.full_name, admin_group_path(group)
        end
        column :volume
        column :admin
        column :accepted_at
        column :archived_at
      end
    end

    render 'notifications', { notifications: Notification.includes(:event).where(user_id: user.id).order("id DESC").limit(30) }

    panel("Identities") do
      table_for user.identities.each do |ui|
        column :id
        column :identity_type
        column :uid
        column :name
        column :email
        column :destroy do |uii|
          button_to 'delete', delete_identity_admin_user_path(ui.user), method: :post, params: {identity_id: uii.id}
        end
      end
    end

    panel 'Merge into another user' do
      form action: merge_admin_user_path(user), method: :post do |f|
        f.input type: :hidden, name: :authenticity_token
        f.label "Email address of final user account"
        f.input name: :destination_email
        f.input type: :submit, value: "Merge user"
      end
    end

    panel 'login as user' do
      a(href: login_as_admin_user_path(user), target: "_blank") do
        "Login as #{user.name}"
      end
    end
  end
end
