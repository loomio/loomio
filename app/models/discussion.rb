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

  attr_accessible :group_id, :group, :title

  attr_accessor :comment, :notify_group_upon_creation

  after_create :populate_last_comment_at


  #
  # PERMISSION CHECKS
  #

  def can_be_commented_on_by?(user)
    group.users.include? user
  end

  #
  # COMMENT METHODS
  #

  def add_comment(user, comment)
    if can_be_commented_on_by? user
      comment = Comment.build_from self, user.id, comment
      comment.save
      comment
    end
  end

  def comments
    comment_threads.order("created_at DESC")
  end

  #
  # MISC METHODS
  #

  def has_activity_unread_by?(user)
    user && user.discussion_activity_count(self) > 0
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
  
  def newer_discussion(starting_discussion, user)
    # greater than finds newer
    #TODO test without all_dicussions
    newer_discussion = Discussion.where("id IN (?) AND updated_at > ?", 
      starting_discussion.group.all_discussions(user).map(&:id).uniq,  
      starting_discussion.updated_at).order("created_at ASC").first
    newer_discussion.nil? ? starting_discussion : newer_discussion
  end
  
  def older_discussion(starting_discussion, user)
    # less than finds older
    #TODO test without all_dicussions
    older_discussion = Discussion.where("id IN (?) AND updated_at < ?", 
      starting_discussion.group.all_discussions(user).map(&:id).uniq,  
      starting_discussion.updated_at).order("created_at ASC").first
    older_discussion.nil? ? starting_discussion : older_discussion
  end
  
  def newer_unread_discussion(user)
    unread_discussion_found = false
    newer_discussion = newer_discussion(self, user)
    newer_unread_discussion = newer_discussion
    #TODO test without all_dicussions
    first_discussion = self.group.all_discussions(user).first
    
    until (unread_discussion_found)
      if (newer_unread_discussion.has_activity_unread_by?(user))
        unread_discussion_found = true
      elsif (newer_unread_discussion.id == first_discussion.id)
        break
      else 
        newer_unread_discussion = newer_discussion(newer_unread_discussion, user)
      end
    end
    
    unread_discussion_found ? newer_unread_discussion : newer_discussion
  end

  def older_unread_discussion(user)
    unread_discussion_found = false
    older_discussion = older_discussion(self, user) 
    older_unread_discussion = older_discussion
    #TODO test without all_dicussions
    last_discussion = self.group.all_discussions(user).last 
    
    until (unread_discussion_found)
      if (older_unread_discussion.has_activity_unread_by?(user))
        unread_discussion_found = true
      elsif (older_unread_discussion.id == last_discussion.id)
        break
      else 
        older_unread_discussion = older_discussion(older_unread_discussion, user)
      end
    end
    
    unread_discussion_found ? older_unread_discussion : older_discussion
  end

  def latest_history_time
    if history.count > 0
      history.first.created_at
    else
      created_at
    end
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
