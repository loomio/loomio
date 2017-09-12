class Discussion < ActiveRecord::Base
  SALIENT_ITEM_KINDS = %w[new_comment
                          stance_created
                          outcome_created
                          poll_created
                        ]

  THREAD_ITEM_KINDS = %w[new_comment
                         discussion_edited
                         discussion_moved
                         poll_created
                         poll_edited
                         stance_created
                         outcome_created
                         poll_expired
                         poll_closed_by_user
                       ]

  include ReadableUnguessableUrls
  include Translatable
  include Reactable
  include HasTimeframe
  include HasMentions
  include HasImportance
  include MessageChannel
  include MakesAnnouncements
  include SelfReferencing
  include UsesOrganisationScope

  scope :archived, -> { where('archived_at is not null') }
  scope :published, -> { where(archived_at: nil, is_deleted: false) }

  scope :last_activity_after, -> (time) { where('last_activity_at > ?', time) }
  scope :order_by_latest_activity, -> { order('discussions.last_activity_at DESC') }

  scope :visible_to_public, -> { published.where(private: false) }
  scope :not_visible_to_public, -> { where(private: true) }
  scope :chronologically, -> { order('created_at asc') }

  validates_presence_of :title, :group, :author
  validate :private_is_not_nil
  validates :title, length: { maximum: 150 }
  validates :description, length: { maximum: Rails.application.secrets.max_message_length }
  validates_inclusion_of :uses_markdown, in: [true,false]
  validate :privacy_is_permitted_by_group

  is_mentionable on: :description
  is_translatable on: [:title, :description], load_via: :find_by_key!, id_field: :key
  has_paper_trail only: [:title, :description, :private, :group_id]

  belongs_to :group, class_name: 'FormalGroup'
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id'
  has_many :polls, dependent: :destroy
  has_many :active_polls, -> { where(closed_at: nil) }, class_name: "Poll"
  has_one :search_vector
  has_many :comments, dependent: :destroy
  has_many :commenters, -> { uniq }, through: :comments, source: :user
  has_many :attachments, as: :attachable, dependent: :destroy

  has_many :events, -> { includes :user }, as: :eventable, dependent: :destroy

  has_many :items, -> { includes(:user).where(kind: THREAD_ITEM_KINDS).order('created_at ASC') }, class_name: 'Event'
  has_many :salient_items, -> { includes(:user).where(kind: SALIENT_ITEM_KINDS).order('created_at ASC') }, class_name: 'Event'

  has_many :discussion_readers

  scope :search_for, ->(query, user, opts = {}) do
    query = sanitize(query)
     select(:id, :key, :title, :result_group_name, :description, :last_activity_at, :rank, "#{query}::text as query")
    .select("ts_headline(discussions.description, plainto_tsquery(#{query}), 'ShortWord=0') as blurb")
    .from(SearchVector.search_for(query, user, opts))
    .joins("INNER JOIN discussions on subquery.discussion_id = discussions.id")
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
  define_counter_cache(:versions_count)       { |discussion| discussion.versions.where(event: :update).count }
  define_counter_cache(:items_count)          { |discussion| discussion.items.count }
  define_counter_cache(:salient_items_count)  { |discussion| discussion.salient_items.count }

  update_counter_cache :group, :discussions_count
  update_counter_cache :group, :public_discussions_count
  update_counter_cache :group, :closed_polls_count

  def update_sequence_info!
    first_item = discussion.salient_items.order({sequence_id: :asc}).first
    last_item =  discussion.salient_items.order({sequence_id: :asc}).last
    discussion.first_sequence_id = first_item&.sequence_id || 0
    discussion.last_sequence_id  = last_item&.sequence_id || 0
    discussion.last_activity_at = last_item&.created_at || created_at
    save!(validate: false)
  end

  def thread_item_created!
    update_sequence_info!
  end

  def thread_item_destroyed!(item)
    update_sequence_info!
    discussion_readers.
      where('last_read_at <= ?', item.created_at).
      map { |dr| dr.viewed!(dr.last_read_at) }

    true
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

  private
  def set_last_activity_at_to_created_at
    update_attribute(:last_activity_at, created_at)
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
