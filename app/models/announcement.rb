class Announcement < ActiveRecord::Base
  include CustomCounterCache::Model

  belongs_to :announceable, polymorphic: true
  belongs_to :author, class_name: "User", required: true

  delegate :guest_group, to: :announceable
  delegate :mailer, to: :announceable
  delegate :group, to: :announceable
  delegate :discussion, to: :announceable
  delegate :poll, to: :announceable
  delegate :body, to: :announceable

  before_validation :ensure_kind

  update_counter_cache :announceable, :announcements_count, only: [:create, :destroy]

  validates :kind, presence: true

  alias :user :author
  attr_accessor :invitation_emails

  def guest_users
    users.where.not(id: group&.members)
  end

  def users
    User.where(id: self.user_ids)
  end

  def invitations
    Invitation.where(id: self.invitation_ids)
  end

  def notified=(notified)
    self.user_ids = self.invitation_emails = []
    notified.uniq.each do |n|
      case n['type']
      when 'Group', 'User' then self.user_ids          += Array(n['notified_ids'])
      when 'Invitation'    then self.invitation_emails += Array(n['id'])
      end
    end
  end

  private

  def ensure_kind
    self.kind ||= :"#{announceable_type.downcase}_announced"
  end
end
