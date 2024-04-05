class Membership < ApplicationRecord
  class InvitationAlreadyUsed < StandardError
    attr_accessor :membership
    def initialize(obj)
      self.membership = obj
    end
  end

  include CustomCounterCache::Model
  include HasVolume
  include HasTimeframe
  include HasExperiences
  scope :in_organisation, -> (group) { includes(:user).where(group_id: group.id_and_subgroup_ids) }

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
  has_many :events, as: :eventable, dependent: :destroy

  scope :dangling,      -> { joins('left join groups g on memberships.group_id = g.id').where('group_id is not null and g.id is null')  }
  scope :active,        -> { where(revoked_at: nil) }
  scope :pending,       -> { active.where(accepted_at: nil) }
  scope :accepted,      -> { where('accepted_at IS NOT NULL') }
  scope :revoked,       -> { where('revoked_at IS NOT NULL') }

  scope :search_for, ->(query) { joins(:user).where("users.name ilike :query or users.username ilike :query or users.email ilike :query", query: "%#{query}%") }

  scope :email_verified, -> { joins(:user).where("users.email_verified": true) }

  scope :for_group, lambda {|group| where(group_id: group)}
  scope :admin, -> { where(admin: true) }

  has_paper_trail only: [:group_id, :user_id, :inviter_id, :admin, :title, :revoked_at, :revoker_id, :volume, :accepted_at]
  delegate :name, :email, to: :user, prefix: :user, allow_nil: true
  delegate :parent, to: :group, prefix: :group, allow_nil: true
  delegate :name, :full_name, to: :group, prefix: :group
  delegate :admins, to: :group, prefix: :group
  delegate :name, to: :inviter, prefix: :inviter, allow_nil: true
  delegate :mailer, to: :user

  update_counter_cache :group, :memberships_count
  update_counter_cache :group, :pending_memberships_count
  update_counter_cache :group, :admin_memberships_count
  update_counter_cache :user,  :memberships_count

  before_create :set_volume

  def author_id
    inviter_id
  end

  def author
    inviter
  end

  def message_channel
    "membership-#{token}"
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

  def stances
    Stance.joins(:poll).
           where("polls.group_id": group_id).
           where(participant_id: user_id)
  end

  private

  def set_volume
    self.volume = user.default_membership_volume if id.nil?
  end
end
