ActiveAdmin.register User do
  actions :index, :edit, :update, :show, :destroy

  filter :name
  filter :username
  filter :email, as: :string
  filter :created_at

  scope :all
  scope :coordinators

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

  collection_action :export_emails_deactivated do
    emails = User.inactive.pluck :email
    render plain: emails.join("\n")
  end

  collection_action :export_emails_fr do
    emails = User.active.where("detected_locale ilike 'fr%'").pluck(:email)
    render plain: emails.join("\n")
  end

  collection_action :export_emails_es do
    query = %w[es ca an].map do |prefix|
      "detected_locale ilike '#{prefix}%'"
    end.join ' or '

    emails = User.active.where(query).pluck(:email)
    render plain: emails.join("\n")
  end

  collection_action :export_emails_other do
    query = %w[fr es ca an].map do |prefix|
      "detected_locale ilike '#{prefix}%'"
    end.join ' or '

    emails = User.active.where.not(query).pluck(:email)
    render plain: emails.join("\n")
  end

  member_action :delete_spam, method: :post do
    user = User.friendly.find(params[:id])
    UserService.delete_spam(user)
    redirect_to admin_users_path, notice: 'User and the groups they created deleted'
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

  show do |user|
    if user.deactivated_at.nil?
      panel("Deactivate") do
        if user.ability.can? :deactivate, user
          button_to 'Deactivate User', deactivate_admin_user_path(user), method: :put, data: {confirm: 'Are you sure you want to deactivate this user?'}
        else
          div "This user can't be deactivated because they are the only coordinator of the following groups:"
          table_for user.adminable_groups.where(type: "FormalGroup").published.select{|g| g.admins.count == 1}.each do |group|
            column :id
            column :name do |group|
              link_to group.name, admin_group_path(group)
            end
          end
        end
      end
    else
      panel("This user account has been deactivated") do
        button_to 'Reactivate User', reactivate_admin_user_path(user), method: :put, data: {confirm: 'Are you sure you want to reactivate this user?'}
      end
    end
    
    attributes_table do
      user.attributes.each do |k,v|
        row k.to_sym
      end
    end

    panel("Memberships") do
      table_for user.memberships.each do |m|
        column :group_id
        column :group_name do |g|
          group = g.group
          link_to group.full_name, admin_group_path(group)
        end
      end
    end

    panel("Reset Password") do
      button_to 'Get link to reset password', reset_password_admin_user_path(user), method: :post
    end

    panel 'Merge into another user' do
      form action: merge_admin_user_path(user), method: :post do |f|
        f.label "Email address of final user account"
        f.input name: :destination_email
        f.input type: :submit, value: "Merge user"
      end
    end

    if user.deactivation_response.present?
      panel("Deactivation query response") do
        div "#{user.deactivation_response.body}"
      end
    end
  end

  member_action :merge, method: :post do
    source = User.friendly.find(params[:id])
    destination = User.find_by!(email: params[:destination_email].strip)
    MigrateUserService.delay.migrate!(source: source, destination: destination)
    redirect_to admin_user_path(destination)
  end

  member_action :deactivate, method: :put do
    user = User.friendly.find(params[:id])
    user.deactivate!
    redirect_to admin_users_path, :notice => "User account deactivated"
  end

  member_action :reactivate, method: :put do
    user = User.friendly.find(params[:id])
    user.reactivate!
    redirect_to admin_users_path, :notice => "User account activated"
  end

  member_action :reset_password, method: :post do
    user = User.friendly.find(params[:id])
    raw = user.send(:set_reset_password_token)

    render plain: edit_user_password_path(reset_password_token: raw)
  end
end
