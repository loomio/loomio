class Announcement < ApplicationRecord
  include CustomCounterCache::Model

  belongs_to :event, required: true
  belongs_to :author, class_name: "User", required: true

  has_many :announcees, dependent: :destroy
  has_many :users,       through: :announcees, source: :announceable, source_type: 'User'
  has_many :invitations, through: :announcees, source: :announceable, source_type: 'Invitation'
  has_many :groups,      through: :announcees, source: :announceable, source_type: 'Group'
  attr_accessor :notified

  delegate :kind, to: :event
  delegate :eventable, to: :event, allow_nil: true
  delegate :members, to: :eventable, allow_nil: true
  delegate :guest_group, to: :eventable, allow_nil: true
  delegate :memberships, to: :guest_group
  delegate :update_announcements_count, to: :eventable, allow_nil: true
  delegate :group, to: :eventable, allow_nil: true
  delegate :poll, to: :eventable, allow_nil: true
  delegate :discussion, to: :eventable, allow_nil: true
  delegate :documents, to: :eventable, allow_nil: true
  delegate :body, to: :eventable, allow_nil: true
  delegate :invitation_intent, to: :eventable, allow_nil: true
  delegate :mailer, to: :eventable, allow_nil: true

  attr_accessor :model_id, :model_type

  after_create :update_announcements_count
  after_destroy :update_announcements_count

  alias :user :author

  def poll_type
    eventable.poll&.poll_type if eventable.respond_to?(:poll)
  end

  def announce_and_invite!
    announcees.import  Array(notified).uniq.map { |n| build_announcee(n) }
    memberships.import users_to_invite.map      { |u| build_membership(u) }
  end

  def users_to_announce
    @users_to_announce ||= User.where(id: announcees.pluck(:user_ids).flatten.uniq)
  end

  def users_to_invite
    @users_to_invite ||= users_to_announce.where.not(id: members.pluck(:id))
  end

  def ensure_event
    self.event ||= model.events.create(kind: :"#{model_type.downcase}_announced", user: user)
  end

  def model
    @model ||= event&.eventable || model_type.classify.constantize.find(model_id) if model_type && model_id
  rescue NameError
    nil
  end

  private

  def build_membership(u)
    Membership.new(user: u, inviter: author)
  end

  def build_announcee(n)
    Announcee.new(
      announceable_id:   munge_id(n),
      announceable_type: n['type'],
      user_ids:          Array(n['notified_ids']).map(&:to_s),
      created_at:        self.created_at
    )
  end

  def munge_id(n)
    return n['id'] unless n['type'] == 'Invitation'
    Invitation.create!(recipient_email: n['id'], group: guest_group, inviter: author, intent: invitation_intent).id
  end
end
