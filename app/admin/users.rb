ActiveAdmin.register User do
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
  end
end
