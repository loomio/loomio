class GroupMailer < ActionMailer::Base
  default :from => "noreply@tautoko.co.nz"   

  def new_membership_request(group)
    @group = group
    @admins = @group.admins.map(&:email)
    mail(:to => @admins, :subject => "[Tautoko: #{@group.name}] Membership waiting approval.")
  end
end
