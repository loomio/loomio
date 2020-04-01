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

  scope :active,        -> { not_archived.accepted }
  scope :archived,      -> { where('archived_at IS NOT NULL') }
  scope :not_archived,  -> { where(archived_at: nil) }
  scope :pending,       -> { where(accepted_at: nil) }
  scope :accepted,      -> { where('accepted_at IS NOT NULL') }

  scope :guest,  -> { joins(:group).where("groups.type": "GuestGroup") }
  scope :formal, -> { joins(:group).where("groups.type": "FormalGroup") }

  scope :search_for, ->(query) { joins(:user).where("users.name ilike :query or users.username ilike :query or users.email ilike :query", query: "%#{query}%") }

  scope :email_verified, -> { joins(:user).where("users.email_verified": true) }

  scope :for_group, lambda {|group| where(group_id: group)}
  scope :admin, -> { where(admin: true) }

  delegate :name, :email, to: :user, prefix: :user
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

  private

  def set_volume
    self.volume = user.default_membership_volume if id.nil?
  end
end
