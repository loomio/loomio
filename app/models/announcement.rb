class Announcement < ActiveRecord::Base
  belongs_to :announceable, polymorphic: true
  belongs_to :user
  before_create :create_invitations!, if: :invitation_emails

  attr_writer :invitation_emails

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
