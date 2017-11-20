class Announcement < ActiveRecord::Base
  belongs_to :announceable, polymorphic: true
  belongs_to :author, class_name: "User", required: true

  delegate :guest_group, to: :announceable
  delegate :mailer, to: :announceable
  delegate :group, to: :announceable

  alias :user :author
  attr_accessor :invitation_emails

  def users
    User.where(id: self.user_ids)
  end

  def invitations
    Invitation.where(id: self.invitation_ids)
  end

  def notified=(notified)
    self.user_ids = self.invitation_emails = []
    notified.each do |n|
      case n['type']
      when 'Group', 'User' then self.user_ids          += Array(n['notified_ids'])
      when 'Invitation'    then self.invitation_emails += Array(n['id'])
      end
    end
  end
end
