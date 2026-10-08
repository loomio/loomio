class Membership < ApplicationRecord
  class InvitationAlreadyUsed < StandardError
    attr_accessor :membership
    def initialize(obj)
      self.membership = obj
    end
  end

  include HasVolume
  include HasTimeframe
  include HasExperiences
  include HasNotifications
  extend FriendlyId
  extend HasTokens
  friendly_id :token
  initialized_with_token :token

  validates_presence_of :group, :user
  validates_uniqueness_of :user_id, scope: :group_id

  belongs_to :group
  belongs_to :user
  belongs_to :inviter, class_name: 'User'
  belongs_to :revoker, class_name: 'User'
  scope :active,        -> { where(revoked_at: nil) }
  scope :pending,       -> { active.where(accepted_at: nil) }
  scope :accepted,      -> { where('accepted_at IS NOT NULL') }
  scope :revoked,       -> { where('revoked_at IS NOT NULL') }
  scope :delegates,     -> { where(delegate: true) }

  scope :search_for, ->(query) { joins(:user).where("users.name ilike :query or users.username ilike :query or users.email ilike :query", query: "%#{query}%") }

  scope :email_verified, -> { joins(:user).where("users.email_verified": true) }

  scope :for_group, lambda {|group| where(group_id: group)}
  scope :admin, -> { where(admin: true) }

  has_paper_trail only: [:group_id, :user_id, :inviter_id, :admin, :delegate, :title, :revoked_at, :revoker_id, :volume_email, :volume_push, :accepted_at]
  delegate :name, :email, to: :user, prefix: :user, allow_nil: true
  delegate :parent, to: :group, prefix: :group, allow_nil: true
  delegate :name, :full_name, to: :group, prefix: :group
  delegate :admins, to: :group, prefix: :group
  delegate :name, to: :inviter, prefix: :inviter, allow_nil: true
  delegate :mailer, to: :user

  after_create :add_membership_counts
  after_update :change_membership_counts, if: -> { saved_changes.keys.intersect?(%w[group_id user_id revoked_at accepted_at admin]) }
  after_destroy :remove_membership_counts

  before_create :set_volume
  after_save :remove_group_follow, if: :active_membership_saved?

  def title_model
    group
  end

  def author_id
    inviter_id
  end

  def author
    inviter
  end



  def make_admin!
    update_attribute(:admin, true)
  end

  def topic_readers
    TopicReader
      .joins("INNER JOIN topics ON topics.id = topic_readers.topic_id")
      .where(user_id: user_id)
      .where("topics.group_id = ?", group_id)
  end

  def stances
    Stance.joins(:poll).
           joins("LEFT JOIN topics t ON t.id = polls.topic_id").
           where("t.group_id": group_id).
           where(participant_id: user_id)
  end

  private

  def active_membership_saved?
    revoked_at.nil? && (previous_changes.key?('id') || previous_changes.key?('revoked_at'))
  end

  def remove_group_follow
    GroupFollow.where(group_id: group_id, user_id: user_id).delete_all
  end

  def set_volume
    return unless id.nil?

    self.volume_email = user.volume_email_default
    self.volume_push = user.volume_push_default
  end

  # Compute old/new contributions rather than recounting on every save. A
  # membership title, delivery preference or vote weight changes no counts.
  # The distinct organization total is rebuilt only when its membership set
  # changes; two subgroup memberships can represent the same person.
  def add_membership_counts
    apply_membership_counts(nil, attributes)
  end

  def change_membership_counts
    before = attributes.merge(saved_changes.transform_values(&:first))
    apply_membership_counts(before, attributes)
  end

  def remove_membership_counts
    apply_membership_counts(attributes, nil)
  end

  def apply_membership_counts(before, after)
    groups = Hash.new { |hash, id| hash[id] = Hash.new(0) }
    users = Hash.new { |hash, id| hash[id] = Hash.new(0) }
    [[before, -1], [after, 1]].each do |state, delta|
      next unless state && state['revoked_at'].nil?

      counts = groups[state['group_id']]
      counts[:memberships_count] += delta
      counts[:pending_memberships_count] += delta if state['accepted_at'].nil?
      counts[:admin_memberships_count] += delta if state['admin']
      users[state['user_id']][:memberships_count] += delta
    end
    RecordCountService.adjust!(User, users, records: [user])
    RecordCountService.adjust!(Group, groups, records: [group])

    membership_set = ->(state) { state && state['revoked_at'].nil? ? state.values_at('group_id', 'user_id') : nil }
    if membership_set.call(before) != membership_set.call(after)
      Group.update_org_members_count_for_group_ids([before&.fetch('group_id'), after&.fetch('group_id')])
    end
  end
  private :add_membership_counts, :change_membership_counts, :remove_membership_counts, :apply_membership_counts
end
