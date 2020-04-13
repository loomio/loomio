class Group < ApplicationRecord
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include SelfReferencing
  include MessageChannel
  include GroupPrivacy
  include HasEvents
  extend HasTokens

  initialized_with_token :token

  belongs_to :creator, class_name: 'User'
  alias_method :author, :creator

  belongs_to :parent, class_name: 'Group'

  has_many :discussions,             foreign_key: :group_id, dependent: :destroy
  has_many :public_discussions, -> { visible_to_public }, foreign_key: :group_id, dependent: :destroy, class_name: 'Discussion'
  has_many :comments, through: :discussions

  has_many :all_memberships, dependent: :destroy, class_name: 'Membership'
  has_many :all_members, through: :all_memberships, source: :user

  has_many :memberships, -> { where archived_at: nil }
  has_many :members, through: :memberships, source: :user

  has_many :accepted_memberships, -> { accepted }, class_name: 'Membership'
  has_many :accepted_members, through: :accepted_memberships, source: :user

  has_many :admin_memberships, -> { where admin: true, archived_at: nil }, class_name: 'Membership'
  has_many :admins, through: :admin_memberships, source: :user

  has_many :membership_requests, dependent: :destroy
  has_many :pending_membership_requests, -> { where response: nil }, class_name: 'MembershipRequest'

  has_many :polls, foreign_key: :group_id, dependent: :destroy
  has_many :public_polls, through: :public_discussions, dependent: :destroy, source: :polls

  has_many :documents, as: :model, dependent: :destroy

  include GroupExportRelations

  scope :archived, -> { where('archived_at IS NOT NULL') }
  scope :published, -> { where(archived_at: nil) }

  delegate :locale, to: :creator, allow_nil: true

  define_counter_cache(:polls_count)               { |group| group.polls.count }
  define_counter_cache(:closed_polls_count)        { |group| group.polls.closed.count }
  define_counter_cache(:memberships_count)         { |group| group.memberships.count }
  define_counter_cache(:pending_memberships_count) { |group| group.memberships.pending.count }
  define_counter_cache(:admin_memberships_count)   { |group| group.admin_memberships.count }

  def discussion_id
    nil
  end

  def active_memberships_count
    memberships_count - pending_memberships_count
  end

  def poll_id
    nil
  end

  def mailer
    GroupMailer
  end

  def message_channel
    "/group-#{self.key}"
  end

  def parent_or_self
    parent || self
  end

  def add_member!(user, inviter: nil)
    save! unless persisted?
    self.memberships.find_or_create_by!(user: user) do |m|
      m.inviter     = inviter
      m.accepted_at = DateTime.now
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def membership_for(user)
    memberships.find_by(user_id: user.id)
  end

  def add_members!(users, inviter: nil)
    users.map { |user| add_member!(user, inviter: inviter) }
  end

  def add_admin!(user)
    add_member!(user).tap do |m|
      m.make_admin!
      update(creator: user) if creator.blank?
    end.reload
  end
end
