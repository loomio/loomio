class UserMailer < ActionMailer::Base
  default :from => "noreply@tautoko.co.nz"

  def group_membership_approved(user, group)
    @user = user
    @group = group
    mail(:to => user.email, :subject => "[Loomio: #{group.name}] Membership approved.")
  end
end
