class Discussion < ActiveRecord::Base
  class AuthorValidator < ActiveModel::Validator
    def validate(record)
      unless (record.group.nil? || record.group.users.include?(record.author))
        record.errors[:author] << 'must be a member of the discussion group'
      end
    end
  end

  validates_with AuthorValidator
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

  attr_accessible :group_id, :group, :title, :description

  attr_accessor :comment, :notify_group_upon_creation

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

  def has_activity_unread_by?(user)
    user && user.discussion_activity_count(self) > 0
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

  def update_activity
    self.activity += 1
    save
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
