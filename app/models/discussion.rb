class Discussion < ActiveRecord::Base
  default_scope -> {where(is_deleted: false)}
  scope :active_since, lambda {|some_time| where('created_at >= ? or last_comment_at >= ?', some_time, some_time)}

  validates_presence_of :title, :group, :author
  validates :title, :length => { :maximum => 150 }
  validates_inclusion_of :uses_markdown, :in => [true,false]

  acts_as_commentable
  has_paper_trail :only => [:title, :description]

  belongs_to :group, :counter_cache => true
  belongs_to :author, class_name: 'User'
  has_many :motions, :dependent => :destroy
  has_many :closed_motions,
    :class_name => 'Motion',
    :conditions => { phase: 'closed' },
    :order => "close_at desc"
  has_many :votes, through: :motions
  has_many :comments,  :as => :commentable, :dependent => :destroy
  has_many :users_with_comments, :through => :comments,
    :source => :user, :uniq => true
  has_many :events, :as => :eventable, :dependent => :destroy

  delegate :users, :to => :group, :prefix => :group
  delegate :full_name, :to => :group, :prefix => :group
  delegate :email, :to => :author, :prefix => :author

  attr_accessible :group_id, :group, :title, :description, :uses_markdown

  attr_accessor :comment, :notify_group_upon_creation

  after_create :populate_last_comment_at
  after_create :fire_new_discussion_event

  def group_users_without_discussion_author
    group.users.where(User.arel_table[:id].not_eq(author.id))
  end
  #
  # COMMENT METHODS
  #

  def can_be_commented_on_by?(user)
    group.users.include? user
  end

  def add_comment(user, comment, uses_markdown)
    if can_be_commented_on_by? user
      comment = Comment.build_from self, user.id, comment, uses_markdown
      comment.save!
      comment
    end
  end

  #
  # MISC METHODS
  #

  def read_log_for(user)
    DiscussionReadLog.where('discussion_id = ? AND user_id = ?',
      id, user.id).first
  end

  def never_read_by(user)
    (user.nil? || read_log_for(user).nil?)
  end

  def number_of_comments_since_last_looked(user)
    if user
      return number_of_comments_since(last_looked_at_by(user)) if last_looked_at_by(user)
    end
    comments.count
  end

  def update_total_views
    self.total_views += 1
    save!
  end

  def last_looked_at_by(user)
    read_log_for(user).discussion_last_viewed_at if read_log_for(user)
  end

  def number_of_comments_since(time)
    comments.where('comments.created_at > ?', time).count
  end

  def has_activity_since_group_last_viewed?(user)
    membership = group.membership(user)
    last_viewed_at = last_looked_at_by(user)
    if membership
      return true if group.discussions
        .includes(:comments)
        .where('discussions.id = ? AND comments.user_id <> ? AND comments.created_at > ? AND comments.created_at > ?', id, user.id, membership.group_last_viewed_at, last_viewed_at)
        .count > 0
      return true if never_read_by(user) && (created_at > membership.group_last_viewed_at)
    end
    false
  end

  def current_motion_close_at
    current_motion.close_at
  end

  def current_motion
    motion = motions.where("phase = 'voting'").last
    if motion
      motion.close_if_expired
      motion if motion.voting?
    end
  end

  def history
    (comments + votes + motions).sort!{ |a,b| b.created_at <=> a.created_at }
  end

  def activity
    Event.includes(:eventable).where("discussion_id = ?", id).order('created_at DESC')
  end

  def filtered_activity
    filtered_activity = []
    previous_event = activity.first
    activity.reverse.each do |event|
      filtered_activity << event unless event.is_repetition_of?(previous_event)
      previous_event = event
    end
    filtered_activity.reverse
  end

  def participants
    included_participants = users_with_comments.all
    included_participants << author
    motions.each do |motion|
      included_participants << motion.author
    end
    included_participants.uniq
  end

  def latest_comment_time
    return comments.order('created_at DESC').first.created_at if comments.count > 0
    created_at
  end

  def has_previous_versions?
    previous_version.nil? ? false : previous_version.id.present?
  end

  def last_versioned_at
    return previous_version.version.created_at if has_previous_versions?
    created_at
  end

  def set_description!(description, uses_markdown, user)
    self.description = description
    self.uses_markdown = uses_markdown
    save!
    fire_edit_description_event(user)
  end

  def set_title!(title, user)
    self.title = title
    save!
    fire_edit_title_event(user)
  end

  def delayed_destroy
    self.update_attribute(:is_deleted, true)
    self.delay.destroy
  end

  private

    def populate_last_comment_at
      self.last_comment_at = created_at
      save
    end

    def fire_edit_title_event(user)
      Events::DiscussionTitleEdited.publish!(self, user)
    end

    def fire_edit_description_event(user)
      Events::DiscussionDescriptionEdited.publish!(self, user)
    end

    def fire_new_discussion_event
      Events::NewDiscussion.publish!(self)
    end
end
