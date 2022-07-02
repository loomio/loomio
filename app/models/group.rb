class Group < ApplicationRecord
  include HasTimeframe
  include HasRichText
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include SelfReferencing
  include MessageChannel
  include GroupPrivacy
  include HasEvents
  include Translatable

  extend HasTokens
  extend NoSpam

  is_rich_text    on: :description
  is_translatable on: :description
  initialized_with_token :token
  no_spam_for :name, :description

  belongs_to :creator, class_name: 'User'
  alias_method :author, :creator

  belongs_to :parent, class_name: 'Group'
  scope :dangling, -> { joins('left join groups parents on parents.id = groups.parent_id').where('groups.parent_id is not null and parents.id is null')  }
  scope :empty_no_subscription, -> { joins('left join subscriptions on subscription_id = groups.subscription_id').where('subscriptions.id is null and groups.parent_id is null').where('memberships_count < 2 AND discussions_count < 3 and polls_count < 2 and subgroups_count = 0').where('groups.created_at < ?', 1.year.ago) }
  scope :expired_trial, -> { joins(:subscription).where('subscriptions.plan = ?', 'trial').where('subscriptions.expires_at < ?', 12.months.ago) }
  scope :any_trial, -> { joins(:subscription).where('subscriptions.plan = ?', 'trial') }
  scope :expired_demo, -> { joins(:subscription).where('subscriptions.plan = ?', 'demo').where('groups.created_at < ?', 3.days.ago) }
  scope :not_demo, -> { joins(:subscription).where('subscriptions.plan != ?', 'demo') }

  has_many :discussions, dependent: :destroy
  has_many :public_discussions, -> { visible_to_public }, foreign_key: :group_id, class_name: 'Discussion'
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

  has_many :polls, dependent: :destroy

  has_many :documents, as: :model, dependent: :destroy
  has_many :requested_users, through: :membership_requests, source: :user
  has_many :comments, through: :discussions
  has_many :public_comments, through: :public_discussions, source: :comments

  has_many :group_identities, dependent: :destroy, foreign_key: :group_id
  has_many :identities, through: :group_identities
  has_many :webhooks, dependent: :destroy
  has_many :chatbots, dependent: :destroy

  has_many :discussion_documents,        through: :discussions,        source: :documents
  has_many :poll_documents,              through: :polls,              source: :documents
  has_many :comment_documents,           through: :comments,           source: :documents
  has_many :tags, foreign_key: :group_id

  has_one :group_survey, required: false, foreign_key: :group_id

  belongs_to :subscription

  has_many :subgroups,
           -> { where(archived_at: nil) },
           class_name: 'Group',
           foreign_key: 'parent_id'
  has_many :all_subgroups, dependent: :destroy, class_name: 'Group', foreign_key: :parent_id
  include GroupExportRelations

  scope :with_serializer_includes, -> { includes(:subscription) }
  scope :archived, -> { where('archived_at IS NOT NULL') }
  scope :published, -> { where(archived_at: nil) }
  scope :parents_only, -> { where(parent_id: nil) }
  scope :visible_to_public, -> { published.where(is_visible_to_public: true) }
  scope :hidden_from_public, -> { published.where(is_visible_to_public: false) }
  scope :in_organisation, ->(group) { where(id: group.id_and_subgroup_ids) }

  scope :explore_search, ->(query) { where("name ilike :q or description ilike :q", q: "%#{query}%") }

  scope :by_slack_team, ->(team_id) {
     joins(:identities)
    .where("(omniauth_identities.custom_fields->'slack_team_id')::jsonb ? :team_id", team_id: team_id)
  }

  scope :by_slack_channel, ->(channel_id) {
     joins(:group_identities)
    .where("(group_identities.custom_fields->'slack_channel_id')::jsonb ? :channel_id", channel_id: channel_id)
  }

  scope :search_for, ->(query) { where("name ilike :q", q: "%#{query}%") }

  validates_presence_of :name
  validates :name, length: { maximum: 250 }

  validate :limit_inheritance
  validates :subscription, absence: true, if: :is_subgroup?
  validate :handle_is_valid
  validates :handle, uniqueness: true, allow_nil: true

  delegate :locale, to: :creator, allow_nil: true
  delegate :time_zone, to: :creator, allow_nil: true
  delegate :date_time_pref, to: :creator, allow_nil: true

  define_counter_cache(:polls_count)                { |g| g.polls.count }
  define_counter_cache(:closed_polls_count)         { |g| g.polls.closed.count }
  define_counter_cache(:memberships_count)          { |g| g.memberships.count }
  define_counter_cache(:pending_memberships_count)  { |g| g.memberships.pending.count }
  define_counter_cache(:admin_memberships_count)    { |g| g.admin_memberships.count }
  define_counter_cache(:public_discussions_count)   { |g| g.discussions.visible_to_public.count }
  define_counter_cache(:discussions_count)          { |g| g.discussions.kept.count }
  define_counter_cache(:open_discussions_count)     { |g| g.discussions.is_open.count }
  define_counter_cache(:closed_discussions_count)   { |g| g.discussions.is_closed.count }
  define_counter_cache(:template_discussions_count) { |g| g.discussions.templates.count }
  define_counter_cache(:subgroups_count)            { |g| g.subgroups.published.count }
  update_counter_cache(:parent, :subgroups_count)

  delegate :include?, to: :users, prefix: true
  delegate :members, to: :parent, prefix: true

  delegate :slack_team_id, to: :slack_identity, allow_nil: true
  delegate :slack_channel_id, to: :slack_identity, allow_nil: true
  delegate :slack_team_name, to: :slack_identity, allow_nil: true
  delegate :slack_channel_name, to: :slack_identity, allow_nil: true

  has_one_attached :cover_photo, dependent: :detach
  has_one_attached :logo, dependent: :detach

  has_paper_trail only: [:name,
                         :parent_id,
                         :description,
                         :description_format,
                         :handle,
                         :archived_at,
                         :parent_members_can_see_discussions,
                         :key,
                         :is_visible_to_public,
                         :is_visible_to_parent_members,
                         :discussion_privacy_options,
                         :members_can_add_members,
                         :membership_granted_upon,
                         :members_can_edit_discussions,
                         :members_can_edit_comments,
                         :members_can_delete_comments,
                         :members_can_raise_motions,
                         :members_can_start_discussions,
                         :members_can_create_subgroups,
                         :creator_id,
                         :subscription_id,
                         :members_can_announce,
                         :new_threads_max_depth,
                         :new_threads_newest_first,
                         :admins_can_edit_user_content,
                         :listed_in_explore]

  validates :description, length: { maximum: Rails.application.secrets.max_message_length }
  before_validation :ensure_handle_is_not_empty

  def logo_url(size = 512)
    return nil unless logo.attached?
    size = size.to_i
    Rails.application.routes.url_helpers.rails_representation_path(
      logo.representation(resize_to_limit: [size,size], saver: {quality: 80, strip: true}),
      only_path: true
    )
  end

  def cover_url(size = 512) # 2048x512 or 1024x256 normal res
    return nil unless cover_photo.attached?
    Rails.application.routes.url_helpers.rails_representation_path(
      cover_photo.representation(HasRichText::PREVIEW_OPTIONS.merge(resize_to_limit: [size*4,size])),
      only_path: true
    )
  end

  def self_or_parent_logo_url(size = 512)
    logo_url(size) || (parent && parent.logo_url(size))
  end

  def self_or_parent_cover_url(size = 512)
    cover_url(size) || (parent && parent.cover_url(size))
  end

  def existing_member_ids
    member_ids
  end

  def author_id
    creator_id
  end
  
  def user_id
    creator_id
  end

  def discussion_id
    nil
  end

  def accepted_memberships_count
    memberships_count - pending_memberships_count
  end

  def poll_id
    nil
  end

  def poll
    nil
  end

  def title
    name
  end

  def guests
    User.none
  end

  def message_channel
    "/group-#{self.key}"
  end

  def parent_or_self
    parent || self
  end

  def self_and_subgroups
    Group.where(id: [id].concat(subgroup_ids))
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

  def ensure_handle_is_not_empty
    self.handle = nil if self.handle.to_s.strip == ""
  end

  def archive!
    Group.where(id: id_and_subgroup_ids).update_all(archived_at: DateTime.now)
    Membership.where(group_id: id_and_subgroup_ids).update_all(archived_at: DateTime.now)
    reload
  end

  def unarchive!
    Group.where(id: all_subgroup_ids.concat([id])).update_all(archived_at: nil)
    Membership.where(group_id: all_subgroup_ids.concat([id])).update_all(archived_at: nil)
    reload
  end

  def org_memberships_count
    Membership.not_archived.where(group_id: id_and_subgroup_ids).count('distinct user_id')
  end

  def org_members_count
    Membership.active.where(group_id: id_and_subgroup_ids).count('distinct user_id')
  end

  def org_discussions_count
    Group.where(id: id_and_subgroup_ids).sum(:discussions_count)
  end

  def org_polls_count
    Group.where(id: id_and_subgroup_ids).sum(:polls_count)
  end

  def has_max_members
    parent_group = parent_or_self
    subscription = Subscription.for(parent_group)
    subscription.max_members && parent_group.org_memberships_count >= subscription.max_members
  end

  def is_subgroup_of_hidden_parent?
    is_subgroup? and parent.is_hidden_from_public?
  end

  def is_parent?
    parent_id.blank?
  end

  def is_subgroup?
    !is_parent?
  end

  def admin_email
    admins.first.email
  end

  def full_name
    if is_subgroup?
      [parent&.name, name].compact.join(' - ')
    else
      name
    end
  end

  def id_and_subgroup_ids
    subgroup_ids.concat([id]).compact
  end

  def slack_identity
    identity_for(:slack)
  end

  def identity_for(type)
    group_identities.joins(:identity).find_by("omniauth_identities.identity_type": type)
  end

  private
  def variant_path(variant)
    Rails.application.routes.url_helpers.rails_representation_path(variant, only_path: true)
  end

  def handle_is_valid
    self.handle = nil if self.handle.to_s.strip == "" || (is_subgroup? && parent.handle.nil?)
    return if handle.nil?
    self.handle = handle.parameterize
    if is_subgroup? && parent.handle && !handle.starts_with?("#{parent.handle}-")
      errors.add(:handle, I18n.t(:'group.error.handle_must_begin_with_parent_handle', parent_handle: parent.handle))
    end
  end

  def limit_inheritance
    if parent_id.present?
      errors[:base] << "Can't set a subgroup as parent" unless parent.parent_id.nil?
    end
  end
end
