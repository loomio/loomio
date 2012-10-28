class Discussion < ActiveRecord::Base

  attr_accessible :group_id, :group, :title, :description

  attr_accessor :comment, :notify_group_upon_creation

  validates_presence_of :title, :group, :author
  validates :title, :length => { :maximum => 150 }

  acts_as_commentable

  belongs_to :group
  belongs_to :author, class_name: 'User'
  has_many :motions
  has_many :votes, through: :motions
  has_many :comments,  :as => :commentable
  has_many :users_with_comments, :through => :comments,
    :source => :user, :uniq => true
  has_many :events, :as => :eventable, :dependent => :destroy

  delegate :users, :to => :group, :prefix => :group
  delegate :full_name, :to => :group, :prefix => :group
  delegate :email, :to => :author, :prefix => :author

  after_create :populate_last_comment_at


  #
  # COMMENT METHODS
  #

  def can_be_commented_on_by?(user)
    group.users.include? user
  end

  def add_comment(user, comment)
    if can_be_commented_on_by? user
      comment = Comment.build_from self, user.id, comment
      comment.save
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

  def unread_by(user)
    membership = user.group_membership(group)
    if membership
      has_unread_comments = number_of_comments_since_last_looked(user) > 0
      created_after_user_joined_group = (created_at > membership.created_at)
      has_unread_comments ||
        (created_after_user_joined_group && never_read_by(user))
    else
      false
    end
  end

  def never_read_by(user)
    read_log_for(user).nil?
  end

  def number_of_comments_since_last_looked(user)
    last_viewed_at = last_looked_at_by(user)
    number_of_comments_since(last_viewed_at)
  end

  def last_looked_at_by(user)
    discussion_read_log = read_log_for(user)
    if discussion_read_log.blank?
      membership = Membership.where(:group_id => group_id,
                                    :user_id => user.id)
      membership.exists? ? membership.first.created_at : nil
    else
      discussion_read_log.discussion_last_viewed_at
    end
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

  def current_motion_close_date
    current_motion.close_date
  end

  def current_motion
    motion = motions.where("phase = 'voting'").last if motions
    if motion
      motion.open_close_motion
      motion if motion.voting?
    end
  end

  def closed_motion(motion)
    if motion
      motions.find(motion)
    else
      motions.where("phase = 'closed'").order("close_date desc").first
    end
  end

  def history
    (comments + votes + motions).sort!{ |a,b| b.created_at <=> a.created_at }
  end

  def latest_history_time
    if history.count > 0
      history.first.created_at
    else
      created_at
    end
  end

  def participants
    other_participants = []
    # Include discussion author
    unless users_with_comments.find_by_id(author.id)
      other_participants << author
    end
    # Include motion authors
    motions.each do |motion|
      unless users_with_comments.find_by_id(motion.author.id)
        other_participants << motion.author
      end
    end
    users_with_comments.all + other_participants.uniq
  end

  def latest_comment_time
    if comments.count > 0
      comments.order('created_at DESC').first.created_at
    else
      created_at
    end
  end

  private

  def populate_last_comment_at
    self.last_comment_at = created_at
    save
  end
end
