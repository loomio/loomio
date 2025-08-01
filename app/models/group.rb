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
  scope :expired_demo, -> { joins(:subscription).where('subscriptions.plan = ?', 'demo').where('groups.created_at < ?', 7.days.ago) }
  scope :not_demo, -> { joins(:subscription).where('subscriptions.plan != ?', 'demo') }

  has_many :discussions, dependent: :destroy
  has_many :discussion_templates, dependent: :destroy
  has_many :public_discussions, -> { visible_to_public }, foreign_key: :group_id, class_name: 'Discussion'
  has_many :comments, through: :discussions

  has_many :all_memberships, dependent: :destroy, class_name: 'Membership'
  has_many :all_members, through: :all_memberships, source: :user

  has_many :memberships, -> { active }
  has_many :members, through: :memberships, source: :user

  has_many :delegate_memberships, -> { active.delegates }, class_name: "Membership"
  has_many :delegates, through: :delegate_memberships, source: :user

  has_many :accepted_memberships, -> { active.accepted }, class_name: "Membership"
  has_many :accepted_members, through: :accepted_memberships, source: :user

  has_many :admin_memberships, -> { active.where(admin: true) }, class_name: 'Membership'
  has_many :admins, through: :admin_memberships, source: :user

  has_many :membership_requests, dependent: :destroy
  has_many :pending_membership_requests, -> { where response: nil }, class_name: 'MembershipRequest'

  has_many :polls, dependent: :destroy
  has_many :poll_templates, dependent: :destroy

  has_many :documents, as: :model, dependent: :destroy
  has_many :requested_users, through: :membership_requests, source: :user
  has_many :comments, through: :discussions
  has_many :public_comments, through: :public_discussions, source: :comments

  has_many :group_identities, dependent: :destroy, foreign_key: :group_id
  has_many :identities, through: :group_identities
  has_many :chatbots, dependent: :destroy

  has_many :discussion_documents,        through: :discussions,        source: :documents
  has_many :poll_documents,              through: :polls,              source: :documents
  has_many :comment_documents,           through: :comments,           source: :documents
  has_many :tags, foreign_key: :group_id

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
  scope :mention_search, lambda { |q|
    where("groups.name ilike :first OR groups.name ilike :other OR groups.handle ilike :first",
          first: "#{q}%", other: "% #{q}%")
  }
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
  validates :request_to_join_prompt, length: { maximum: 280 }

  validate :limit_inheritance
  validates :subscription, absence: true, if: :is_subgroup?
  validate :handle_is_valid
  validates :handle, uniqueness: true, allow_nil: true

  delegate :locale, to: :creator, allow_nil: true
  delegate :time_zone, to: :creator, allow_nil: true
  delegate :date_time_pref, to: :creator, allow_nil: true

  define_counter_cache(:polls_count)                { |g| g.polls.count }
  define_counter_cache(:closed_polls_count)         { |g| g.polls.closed.count }
  define_counter_cache(:poll_templates_count)       { |g| g.poll_templates.kept.count }
  define_counter_cache(:memberships_count)          { |g| g.memberships.count }
  define_counter_cache(:pending_memberships_count)  { |g| g.memberships.pending.count }
  define_counter_cache(:admin_memberships_count)    { |g| g.admin_memberships.count }
  define_counter_cache(:delegates_count)            { |g| g.memberships.delegates.count }
  define_counter_cache(:public_discussions_count)   { |g| g.discussions.visible_to_public.count }
  define_counter_cache(:discussions_count)          { |g| g.discussions.kept.count }
  define_counter_cache(:open_discussions_count)     { |g| g.discussions.is_open.count }
  define_counter_cache(:closed_discussions_count)   { |g| g.discussions.is_closed.count }
  define_counter_cache(:discussion_templates_count) { |g| g.discussion_templates.kept.count }
  define_counter_cache(:subgroups_count)            { |g| g.subgroups.published.count }
  update_counter_cache(:parent, :subgroups_count)

  delegate :include?, to: :users, prefix: true
  delegate :members, to: :parent, prefix: true

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
                         :listed_in_explore,
                         :attachments]

  validates :description, length: { maximum: AppConfig.app_features[:max_message_length] }
  before_validation :ensure_handle_is_not_empty

  def logo_url(size = 512)
    return nil unless logo.attached?
    size = size.to_i
    Rails.application.routes.url_helpers.rails_representation_path(
      logo.representation(resize_to_limit: [size,size], saver: {quality: 80, strip: true}),
      only_path: true
    )
  rescue ActiveStorage::UnrepresentableError
    self.cover_photo.delete
    nil
  end

  def custom_cover_photo?
    !GroupService::DEFAULT_COVER_PHOTO_FILENAMES.include? cover_photo.filename.to_s
  end

  def cover_url(size = 512) # 2048x512 or 1024x256 normal res
    size = size.to_i
    return nil unless cover_photo.attached?
    Rails.application.routes.url_helpers.rails_representation_path(
      cover_photo.representation(HasRichText::PREVIEW_OPTIONS.merge(resize_to_limit: [size*4,size])),
      only_path: true
    )
  rescue ActiveStorage::UnrepresentableError
    self.cover_photo.delete
    nil
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
    user.save! unless user.persisted?

    if membership = Membership.find_by(user_id: user.id, group_id: id)
      if membership.revoked_at
        membership.update(admin: false, revoked_at: nil, revoker_id: nil, accepted_at: DateTime.now, inviter: inviter)
      end
    else
      membership = Membership.create!(user_id: user.id, group_id: id, inviter: inviter, accepted_at: DateTime.now)
    end

    GenericWorker.perform_async('PollService', 'group_members_added', self.id)
    membership
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
    reload
  end

  def unarchive!
    Group.where(id: id_and_subgroup_ids).update_all(archived_at: nil)
    reload
  end

  def org_members_count
    Membership.active.where(group_id: id_and_subgroup_ids).count('distinct user_id')
  end

  def org_accepted_members_count
    Membership.active.accepted.where(group_id: id_and_subgroup_ids).count('distinct user_id')
  end

  def org_discussions_count
    Group.where(id: id_and_subgroup_ids).sum(:discussions_count)
  end

  def org_polls_count
    Group.where(id: id_and_subgroup_ids).sum(:polls_count)
  end

  def is_trial_or_demo?
    parent_group = parent_or_self
    subscription = Subscription.for(parent_group)
    ['trial', 'demo'].include?(subscription.plan)
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
    subgroup_ids.concat([id]).compact.uniq
  end

  def identity_for(type)
    group_identities.joins(:identity).find_by("omniauth_identities.identity_type": type)
  end

  def poll_template_positions
    self[:info]['poll_template_positions'] ||= {
      'practice_proposal' => 0,
      'check' => 1,
      'advice' => 2,
      'consent' => 3,
      'consensus' => 4,
      'poll' => 5,
      'score' => 6,
      'dot_vote' => 7,
      'ranked_choice' => 8,
      'meeting' => 9,
    }
    self[:info]['poll_template_positions']
  end

  def categorize_poll_templates
    if self[:info].has_key? 'categorize_poll_templates'
      self[:info]['categorize_poll_templates']
    else
      true
    end
  end

  def categorize_poll_templates=(val)
    self[:info]['categorize_poll_templates'] = val
  end

  def hidden_poll_templates
    self[:info]['hidden_poll_templates'] ||= AppConfig.app_features.fetch(:hidden_poll_templates, [])
    self[:info]['hidden_poll_templates']
  end

  def hidden_poll_templates=(val)
    self[:info]['hidden_poll_templates'] = val
  end

  def self.ransackable_attributes(auth_object = nil)
    [
    "admin_memberships_count",
    "admin_tags",
    "admins_can_edit_user_content",
    "archived_at",
    "attachments",
    "category_id",
    "city",
    "closed_discussions_count",
    "closed_motions_count",
    "closed_polls_count",
    "cohort_id",
    "content_locale",
    "country",
    "cover_photo_content_type",
    "cover_photo_file_name",
    "cover_photo_file_size",
    "cover_photo_updated_at",
    "created_at",
    "creator_id",
    "default_group_cover_id",
    "description",
    "description_format",
    "discussion_privacy_options",
    "discussions_count",
    "full_name",
    "handle",
    "id",
    "invitations_count",
    "is_referral",
    "is_visible_to_parent_members",
    "is_visible_to_public",
    "key",
    "listed_in_explore",
    "logo_content_type",
    "logo_file_name",
    "logo_file_size",
    "logo_updated_at",
    "members_can_add_guests",
    "members_can_add_members",
    "members_can_announce",
    "members_can_create_subgroups",
    "members_can_delete_comments",
    "members_can_edit_comments",
    "members_can_edit_discussions",
    "members_can_raise_motions",
    "members_can_start_discussions",
    "members_can_vote",
    "membership_granted_upon",
    "memberships_count",
    "name",
    "new_threads_max_depth",
    "new_threads_newest_first",
    "open_discussions_count",
    "parent_id",
    "parent_members_can_see_discussions",
    "pending_memberships_count",
    "poll_templates_count",
    "polls_count",
    "proposal_outcomes_count",
    "public_discussions_count",
    "recent_activity_count",
    "region",
    "subgroups_count",
    "subscription_id",
    "template_discussions_count",
    "theme_id",
    "updated_at"]
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
