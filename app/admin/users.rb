ActiveAdmin.register User do
  actions :index, :edit, :update, :show, :destroy

  filter :name
  filter :username
  filter :email
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
    actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :email
      f.input :username
      f.input :is_admin
      f.input :angular_ui_enabled
    end
    f.actions
  end

  member_action :delete_spam, method: :post do
    user = User.friendly.find(params[:id])
    UserService.delete_spam(user)
    redirect_to admin_users_url, notice: 'User and the groups they created deleted'
  end

  member_action :update, :method => :put do
    user = User.friendly.find(params[:id])
    user.name = params[:user][:name]
    user.email = params[:user][:email]
    user.username = params[:user][:username]
    user.is_admin = params[:user][:is_admin]
    user.angular_ui_enabled = params[:user][:angular_ui_enabled]
    user.save
    redirect_to admin_users_url, :notice => "User updated"
  end

  show do |user|
    if user.deactivated_at.nil?
      panel("Deactivate") do
        if can? :deactivate, user
          button_to 'Deactivate User', deactivate_admin_user_path(user), method: :put, data: {confirm: 'Are you sure you want to deactivate this user?'}
        else
          div "This user can't be deactivated because they are the only coordinator of the following groups:"
          table_for user.adminable_groups.published.select{|g| g.admins.count == 1}.each do |group|
            column :id
            column :name do |group|
              link_to group.name, [:admin, group]
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
        row k.to_sym if v.present?
      end
    end
    panel("Memberships") do
      table_for user.memberships.each do |m|
        column :group_id
        column :group_name do |g|
          group = g.group
          link_to group.full_name, [:admin, group]
        end
      end
    end

    panel("Reset Password") do
      button_to 'Get link to reset password', reset_password_admin_user_path(user), method: :post
    end

    if user.deactivation_response.present?
      panel("Deactivation query response") do
        div "#{user.deactivation_response.body}"
      end
    end

    panel ("Merge two users") do
      div "#{user.email}, WILL BE DELETED if you continue! Their records will be associated with the email address entered below:"
      form(action: merge_admin_users_path, method: :post) do |f|
        f.input name: :unwanted_user_email, type: :hidden, value: user.email
        f.input name: :wanted_user_email
        f.button :submit, confirm: "Are you sure??"
      end
    end
    active_admin_comments
  end

  member_action :deactivate, method: :put do
    user = User.friendly.find(params[:id])
    user.deactivate!
    redirect_to admin_users_url, :notice => "User account deactivated"
  end

  member_action :reactivate, method: :put do
    user = User.friendly.find(params[:id])
    user.reactivate!
    redirect_to admin_users_url, :notice => "User account activated"
  end

  member_action :reset_password, method: :post do
    user = User.friendly.find(params[:id])
    raw = user.send(:set_reset_password_token)

    render text: edit_user_password_url(reset_password_token: raw)
  end

  collection_action :merge, method: :post do
    begin
      unwanted_user = User.find_by!(email: params[:unwanted_user_email])
      wanted_user = User.find_by!(email: params[:wanted_user_email])
      MigrateUserService.new(old_id: unwanted_user.id, new_id: wanted_user.id).commit!
      redirect_to admin_user_path(wanted_user), notice: "Merged #{params[:unwanted_user_email]} records into #{params[:wanted_user_email]} successfully"
    rescue ActiveRecord::RecordNotFound => e
      render text: "user not found by email: #{params[:wanted_user_email]}"+e.inspect+params.inspect
    end
  end
end
