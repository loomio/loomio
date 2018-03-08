class Group < ApplicationRecord
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include SelfReferencing
  include MessageChannel
  include GroupPrivacy

  belongs_to :creator, class_name: 'User'
  belongs_to :parent, class_name: 'Group'
  has_many :all_memberships, dependent: :destroy, class_name: 'Membership'
  has_many :memberships, -> { where is_suspended: false, archived_at: nil }
  has_many :admin_memberships, -> { where admin: true, archived_at: nil }, class_name: 'Membership'
  has_many :admins, through: :admin_memberships, source: :user

  has_many :membership_requests, dependent: :destroy
  has_many :pending_membership_requests, -> { where response: nil }, class_name: 'MembershipRequest'
  has_many :members, through: :memberships, source: :user

  has_many :invitations, dependent: :destroy

  has_many :discussions, foreign_key: :group_id, dependent: :destroy
  has_many :public_discussions, -> { visible_to_public }, foreign_key: :group_id, dependent: :destroy, class_name: 'Discussion'
  has_many :polls, foreign_key: :group_id, dependent: :destroy
  has_many :public_polls, through: :public_discussions, dependent: :destroy, source: :polls

  scope :archived, -> { where('archived_at IS NOT NULL') }
  scope :published, -> { where(archived_at: nil) }

  delegate :locale, to: :creator, allow_nil: true

  define_counter_cache(:polls_count)               { |group| group.polls.count }
  define_counter_cache(:closed_polls_count)        { |group| group.polls.closed.count }
  define_counter_cache(:memberships_count)         { |group| group.memberships.count }
  define_counter_cache(:admin_memberships_count)   { |group| group.admin_memberships.count }
  define_counter_cache(:invitations_count)         { |group| group.invitations.count }
  define_counter_cache(:pending_invitations_count) { |group| group.invitations.pending.count }
  define_counter_cache(:announcement_recipients_count) { |group| group.memberships.volume_at_least(:normal).count }

  def headcount
    memberships_count + pending_invitations_count
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

  def add_member!(user, invitation: nil, inviter: nil)
    save! unless persisted?
    self.memberships.find_or_create_by!(user: user) do |m|
      m.invitation = invitation
      m.inviter = inviter || invitation&.inviter
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

  def is_guest_group?
    type == "GuestGroup"
  end

  def is_formal_group?
    type == "FormalGroup"
  end

  after_create :guess_cohort
  def guess_cohort
    if self.cohort_id.blank?
      cohort_id = Group.where('cohort_id is not null').order('cohort_id desc').first.try(:cohort_id)
      self.update_attribute(:cohort_id, cohort_id) if cohort_id
    end
  end

end
