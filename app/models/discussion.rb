class Discussion < ApplicationRecord
  include CustomCounterCache::Model
  include ReadableUnguessableUrls
  include Forkable
  include Translatable
  include Reactable
  include HasTimeframe
  include HasEvents
  include HasMentions
  include HasImportance
  include MessageChannel
  include SelfReferencing
  include UsesOrganisationScope
  include HasMailer
  include HasCreatedEvent
  include HasRichText
  extend  NoSpam
  include Discard::Model

  no_spam_for :title, :description

  scope :last_activity_after, -> (time) { where('last_activity_at > ?', time) }
  scope :order_by_latest_activity, -> { order('discussions.last_activity_at DESC') }
  scope :recent, -> { where('last_activity_at > ?', 6.weeks.ago) }
  scope :order_by_importance, -> { order(importance: :desc, last_activity_at: :desc) }

  scope :visible_to_public, -> { kept.where(private: false) }
  scope :not_visible_to_public, -> { kept.where(private: true) }

  scope :is_open, -> { kept.where(closed_at: nil) }
  scope :is_closed, -> { kept.where("closed_at is not null") }

  validates_presence_of :title, :group, :author
  validate :private_is_not_nil
  validates :title, length: { maximum: 150 }
  validates :description, length: { maximum: Rails.application.secrets.max_message_length }
  validate :privacy_is_permitted_by_group

  is_mentionable  on: :description
  is_translatable on: [:title, :description], load_via: :find_by_key!, id_field: :key
  is_rich_text    on: :description
  has_paper_trail only: [:title, :description, :private, :group_id]

  belongs_to :group, class_name: 'Group'
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id'
  has_many :polls, dependent: :destroy
  has_many :active_polls, -> { where(closed_at: nil) }, class_name: "Poll"
  has_one :search_vector

  has_many :comments, dependent: :destroy
  has_many :commenters, -> { uniq }, through: :comments, source: :user
  has_many :documents, as: :model, dependent: :destroy
  has_many :poll_documents,    through: :polls,    source: :documents
  has_many :comment_documents, through: :comments, source: :documents
  has_many :discussion_tags, dependent: :destroy
  has_many :tags, through: :discussion_tags


  has_many :items, -> { includes(:user).thread_events }, class_name: 'Event', dependent: :destroy

  has_many :discussion_readers, dependent: :destroy
  has_many :readers, through: :discussion_readers, source: :user
  has_many :guests, -> { merge DiscussionReader.guests }, through: :discussion_readers, source: :user
  has_many :admin_guests, -> { merge DiscussionReader.admins }, through: :discussion_readers, source: :user

  scope :search_for, ->(fragment) do
     joins("INNER JOIN users ON users.id = discussions.author_id")
    .kept
    .where("discussions.title ilike :fragment OR users.name ilike :fragment", fragment: "%#{fragment}%")
  end

  scope :weighted_search_for, ->(query, user, opts = {}) do
    query = connection.quote(query)
    select(:id, :key, :title, :result_group_name, :result_group_id, :description, :last_activity_at, :rank, "#{query}::text as query")
    .select("ts_headline(discussions.description, plainto_tsquery(#{query}), 'ShortWord=0') as blurb")
    .from(SearchVector.search_for(query, user, opts))
    .joins("INNER JOIN discussions on subquery.discussion_id = discussions.id")
    .kept
    .where('rank > 0')
    .order('rank DESC, last_activity_at DESC')
  end

  delegate :name, to: :group, prefix: :group
  delegate :name, to: :author, prefix: :author
  delegate :users, to: :group, prefix: :group
  delegate :full_name, to: :group, prefix: :group
  delegate :email, to: :author, prefix: :author
  delegate :name_and_email, to: :author, prefix: :author
  delegate :locale, to: :author

  after_create :set_last_activity_at_to_created_at

  define_counter_cache(:closed_polls_count)   { |discussion| discussion.polls.closed.count }
  define_counter_cache(:versions_count)       { |discussion| discussion.versions.count }
  define_counter_cache(:items_count)          { |discussion| discussion.items.count }
  define_counter_cache(:seen_by_count)        { |discussion| discussion.discussion_readers.where("last_read_at is not null").count }

  update_counter_cache :group, :discussions_count
  update_counter_cache :group, :public_discussions_count
  update_counter_cache :group, :open_discussions_count
  update_counter_cache :group, :closed_discussions_count
  update_counter_cache :group, :closed_polls_count

  def author
    super || AnonymousUser.new
  end

  def members
    # User.where(id: group.members.pluck(:id).concat(guests.pluck(:id)).uniq)
    User.active.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      where('(m.id IS NOT NULL AND m.archived_at IS NULL) OR
             (dr.id IS NOT NULL and dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL)')
  end

  def admins
    # User.where(id: group.admins.pluck(:id).concat(admin_guests.pluck(:id)).uniq)
    User.active.
      joins("LEFT OUTER JOIN discussion_readers dr ON dr.discussion_id = #{self.id || 0} AND dr.user_id = users.id").
      joins("LEFT OUTER JOIN memberships m ON m.user_id = users.id AND m.group_id = #{self.group_id || 0}").
      where('(m.admin = TRUE AND m.id IS NOT NULL AND m.archived_at IS NULL) OR
             (dr.admin = TRUE AND dr.id IS NOT NULL and dr.revoked_at IS NULL AND dr.inviter_id IS NOT NULL)')
  end

  def add_guest!(user, inviter)
    if dr = discussion_readers.find_by(user: user)
      dr.update(inviter: inviter)
    else
      discussion_readers.create!(user: user, inviter: inviter, volume: DiscussionReader.volumes[:normal])
    end
  end

  def add_admin!(user, inviter)
    if dr = discussion_readers.find_by(user: user)
      dr.update(inviter: inviter, admin: true)
    else
      discussion_readers.create!(user: user, inviter: inviter, admin: true, volume: DiscussionReader.volumes[:normal])
    end
  end

  def poll_id
    nil
  end

  def created_event_kind
    :new_discussion
  end

  def update_sequence_info!
    discussion.ranges_string =
     RangeSet.serialize RangeSet.reduce RangeSet.ranges_from_list discussion.items.order(:sequence_id).pluck(:sequence_id)
    discussion.last_activity_at = discussion.items.unreadable.order(:sequence_id).last&.created_at || created_at
    update_columns(ranges_string: discussion.ranges_string, last_activity_at: discussion.last_activity_at)
  end

  def public?
    !private
  end

  def inherit_group_privacy!
    if self[:private].nil? and group.present?
      self[:private] = group.discussion_private_default
    end
  end

  def discussion
    self
  end

  def body
    self.description
  end

  def body_format
    self.description_format
  end

  def ranges
    RangeSet.parse(self.ranges_string)
  end

  def first_sequence_id
    Array(ranges.first).first.to_i
  end

  def last_sequence_id
    Array(ranges.last).last.to_i
  end

  # this is insted of a big slow migration
  def ranges_string
    update_sequence_info! if self[:ranges_string].nil?
    self[:ranges_string]
  end

  def is_new_version?
    (['title', 'description', 'private'] & self.changes.keys).any?
  end

  private

  def set_last_activity_at_to_created_at
    update_column(:last_activity_at, created_at)
  end

  def sequence_id_or_0(item)
    item.try(:sequence_id) || 0
  end

  def private_is_not_nil
    errors.add(:private, "Please select a privacy") if self[:private].nil?
  end

  def privacy_is_permitted_by_group
    return unless group.present?
    if self.public? and group.private_discussions_only?
      errors.add(:private, "must be private in this group")
    end

    if self.private? and group.public_discussions_only?
      errors.add(:private, "must be public in this group")
    end
  end
end
