class Discussion < ActiveRecord::Base

  PER_PAGE = 50
  paginates_per PER_PAGE

  include ReadableUnguessableUrls

  scope :archived, -> { where('archived_at is not null') }
  scope :published, -> { where(archived_at: nil, is_deleted: false) }

  scope :active_since, lambda {|time| where('last_activity_at > ?', time)}
  scope :last_comment_after, lambda {|time| where('last_comment_at > ?', time)}
  scope :order_by_latest_comment, order('last_comment_at DESC')

  scope :public, where(private: false)
  scope :private, where(private: true)
  scope :with_motions, where("discussions.id NOT IN (SELECT discussion_id FROM motions WHERE id IS NOT NULL)")
  scope :without_open_motions, where("discussions.id NOT IN (SELECT discussion_id FROM motions WHERE id IS NOT NULL AND motions.closed_at IS NULL)")
  scope :with_open_motions, joins(:motions).merge(Motion.voting)
  scope :joined_to_current_motion, joins('LEFT OUTER JOIN motions ON motions.discussion_id = discussions.id AND motions.closed_at IS NULL')

  scope :not_by_helper_bot, -> { where('author_id NOT IN (?)', User.helper_bots.pluck(:id)) }

  validates_presence_of :title, :group, :author, :group_id
  validate :private_is_not_nil
  validates :title, length: { maximum: 150 }
  validates_inclusion_of :uses_markdown, in: [true,false]
  validate :privacy_is_permitted_by_group

  is_translatable on: [:title, :description], load_via: :find_by_key!, id_field: :key
  has_paper_trail :only => [:title, :description]

  belongs_to :group, :counter_cache => true
  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id' # duplicate author relationship for eager loading
  has_many :motions, :dependent => :destroy
  has_one :current_motion, class_name: 'Motion', conditions: {'motions.closed_at' => nil}, order: 'motions.closed_at asc'
  has_one :most_recent_motion, class_name: 'Motion', order: 'motions.created_at desc'
  has_many :votes, through: :motions
  has_many :comments, dependent: :destroy
  has_many :comment_likes, through: :comments, source: :comment_votes
  has_many :commenters, through: :comments, source: :user, uniq: true
  has_many :events, as: :eventable, dependent: :destroy, include: :user
  has_many :items, class_name: 'Event', include: [{eventable: :user}, :user], order: 'created_at ASC'
  has_many :discussion_readers

  include PgSearch
  pg_search_scope :search, against: [:title, :description],
    using: {tsearch: {dictionary: "english"}}

  delegate :name, to: :group, prefix: :group
  delegate :name, to: :author, prefix: :author
  delegate :users, to: :group, prefix: :group
  delegate :full_name, to: :group, prefix: :group
  delegate :email, to: :author, prefix: :author
  delegate :name_and_email, to: :author, prefix: :author
  delegate :language, to: :author

  before_create :set_last_comment_at

  # don't use this.. it needs to be removed.
  # use DiscussionService.add_comment directly
  def add_comment(author, body, options = {})
    options[:body] = body
    comment = Comment.new(options)
    comment.author = author
    comment.discussion = self
    DiscussionService.add_comment(comment)
    comment
  end

  def archive!
    self.update_attribute(:archived_at, DateTime.now)
  end

  def is_archived?
    archived_at.present?
  end

  def closed_motions
    motions.closed
  end

  def last_collaborator
    return nil if originator.nil?
    User.find_by_id(originator.to_i)
  end

  def group_members_without_discussion_author
    group.users.where(User.arel_table[:id].not_eq(author_id))
  end

  def current_motion_closing_at
    current_motion.closing_at
  end

  def number_of_comments_since(time)
    comments.where('comments.created_at > ?', time).count
  end

  def viewed!
    Discussion.increment_counter(:total_views, id)
    self.total_views += 1
  end

  def participants
    participants = commenters.all
    participants << author
    participants += motion_authors
    participants.uniq
  end

  def motion_authors
    User.find(motions.pluck(:author_id))
  end

  def has_previous_versions?
    (previous_version && previous_version.id)
  end

  def last_versioned_at
    if has_previous_versions?
      previous_version.version.created_at
    else
      created_at
    end
  end

  def activity
    items
  end


  def delayed_destroy
    self.update_attribute(:is_deleted, true)
    self.delay.destroy
  end

  def most_recent_comment
    comments.order("created_at DESC").first
  end

  def comment_deleted!
    refresh_last_comment_at!
    discussion_readers.each(&:reset_counts!)
  end

  def public?
    !private
  end

  def inherit_group_privacy!
    if self[:private].nil? and group.present?
      self[:private] = group.discussion_private_default
    end
  end

  private

  def refresh_last_comment_at!
    if comments.exists?
      last_comment_time = most_recent_comment.created_at
    else
      last_comment_time = created_at
    end
    update_attribute(:last_comment_at, last_comment_time)
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

  def set_last_comment_at
    self.last_comment_at ||= Time.now
  end

  def fire_edit_title_event(user)
    Events::DiscussionTitleEdited.publish!(self, user)
  end

  def fire_edit_description_event(user)
    Events::DiscussionDescriptionEdited.publish!(self, user)
  end
end
