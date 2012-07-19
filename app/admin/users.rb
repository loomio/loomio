ActiveAdmin.register User do
  actions :index, :edit, :update

  index do
    column :name
    column :email
    column "Invitation Link" do |user|
      if user.invitation_token
        link_to "Invite link (#{user.invitation_token})",
          accept_invitation_url(user, :invitation_token => user.invitation_token)
      end
    end
    column :created_at
    column :last_sign_in_at
    column :is_admin
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name, :input_html => { :disabled => true }
      f.input :email, :input_html => { :disabled => true }
      f.input :is_admin
    end
    f.buttons
  end

  member_action :update, :method => :put do
    user = User.find(params[:id])
    user.is_admin = params[:user][:is_admin]
    user.save
    redirect_to admin_users_url, :notice => "User updated"
  end
end
