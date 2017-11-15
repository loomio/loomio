class Announcement < ActiveRecord::Base
  belongs_to :announceable, polymorphic: true
  belongs_to :author, class_name: "User", required: true
  after_create :create_invitations!, if: :invitation_emails

  alias :user :author
  attr_accessor :invitation_emails

  def notified=(notified)
    self.user_ids = self.invitation_emails = []
    notified.each do |n|
      case n['type']
      when 'Group', 'User' then self.user_ids          += Array(n['notified_ids'])
      when 'Invitation'    then self.invitation_emails += Array(n['id'])
      end
    end
  end

  # has_many :users_to_notify, class_name: "User", -> { where(id: self.user_ids) }

  def users_to_notify
    User.where(id: user_ids)
  end

  private

  def create_invitations!
    update(invitation_ids: InvitationService.invite_to_group(
      recipient_emails: invitation_emails,
      group:            announceable.guest_group,
      inviter:          user
    ).pluck(:id)) unless invitation_emails.empty?
  end
  handle_asynchronously :create_invitations!
end
