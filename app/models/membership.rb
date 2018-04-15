class Membership < ApplicationRecord
  class InvitationAlreadyUsed < StandardError; end

  include CustomCounterCache::Model
  include HasVolume
  include HasTimeframe
  include HasExperiences
  include UsesOrganisationScope

  extend FriendlyId
  extend HasTokens
  friendly_id :token
  initialized_with_token :token

  validates_presence_of :group, :user
  validates_uniqueness_of :user_id, scope: :group_id

  belongs_to :group
  belongs_to :user
  belongs_to :inviter, class_name: 'User'
  belongs_to :invitation
  has_many :events, as: :eventable, dependent: :destroy

  scope :active, -> { published.where(is_suspended: false) }
  scope :suspended, -> { where(is_suspended: true) }
  scope :archived, lambda { where('archived_at IS NOT NULL') }
  scope :published, lambda { where(archived_at: nil) }
  scope :sorted_by_group_name, -> { joins(:group).order('groups.full_name') }
  scope :chronologically, -> { order('created_at asc') }
  scope :pending, -> { where(accepted_at: nil) }

  scope :guest,  -> { joins(:group).where("groups.type": "GuestGroup") }
  scope :formal, -> { joins(:group).where("groups.type": "FormalGroup") }

  scope :search_for, ->(query) { joins(:user).where("users.name ilike :query or users.username ilike :query or users.email ilike :query", query: "%#{query}%") }

  scope :for_group, lambda {|group| where(group_id: group)}
  scope :admin, -> { where(admin: true) }
  scope :pending, -> { joins(:user).where("users.email_verified": false) }

  scope :undecided_for, ->(poll) {
     joins("INNER JOIN users ON users.id = memberships.user_id")
    .joins("LEFT OUTER JOIN stances ON stances.participant_id = users.id AND stances.poll_id = #{poll.id}")
    .where(group: [poll.group, poll.guest_group])
    .where('stances.id': nil)
  }

  delegate :name, :email, to: :user, prefix: :user
  delegate :parent, to: :group, prefix: :group, allow_nil: true
  delegate :name, :full_name, to: :group, prefix: :group
  delegate :admins, to: :group, prefix: :group
  delegate :name, to: :inviter, prefix: :inviter, allow_nil: true
  delegate :target_model, to: :invitation, allow_nil: true
  delegate :mailer, to: :user

  update_counter_cache :group, :memberships_count
  update_counter_cache :group, :pending_memberships_count
  update_counter_cache :group, :admin_memberships_count
  update_counter_cache :group, :undecided_user_count
  update_counter_cache :user,  :memberships_count

  before_create :set_volume

  after_destroy :leave_subgroups_of_hidden_parents

  def message_channel
    "membership-#{token}"
  end

  def target_model
    Discussion.find_by(guest_group_id: group_id) ||
    Poll.find_by(guest_group_id: group_id) ||
    group
  end

  def make_admin!
    update_attribute(:admin, true)
  end

  def remove_admin!
    update_attribute(:admin, false)
  end

  def discussion_readers
    DiscussionReader.
      joins(:discussion).
      where("discussions.group_id": group_id).
      where("discussion_readers.user_id": user_id)
  end

  private

  def leave_subgroups_of_hidden_parents
    return unless group&.is_formal_group? && group&.is_hidden_from_public?
    group.subgroups.each do |subgroup|
      subgroup.memberships.where(user_id: user.id).destroy_all
    end
  end

  def set_volume
    self.volume = user.default_membership_volume if group.is_formal_group?
  end
end
