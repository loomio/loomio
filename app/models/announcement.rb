class Announcement < ActiveRecord::Base
  include CustomCounterCache::Model

  belongs_to :event, required: true
  belongs_to :author, class_name: "User", required: true

  delegate :kind, to: :event
  delegate :eventable, to: :event, allow_nil: true
  delegate :guest_group, to: :eventable, allow_nil: true
  delegate :update_announcements_count, to: :eventable, allow_nil: true
  delegate :group, to: :eventable, allow_nil: true
  delegate :poll, to: :eventable, allow_nil: true
  delegate :discussion, to: :eventable, allow_nil: true
  delegate :body, to: :eventable, allow_nil: true
  delegate :mailer, to: :eventable, allow_nil: true

  attr_accessor :model_id, :model_type

  after_create :update_announcements_count
  after_destroy :update_announcements_count

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

  def ensure_event
    self.event ||= model.events.create(kind: :"#{model_type.downcase}_announced", user: user)
  end

  def model
    @model ||= event&.eventable || model_type.classify.constantize.find(model_id) if model_type && model_id
  rescue NameError
    nil
  end
end
