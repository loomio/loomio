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
  
  def next_discussion(starting_discussion, user)
    next_discussion = Discussion.find(:first, 
      starting_discussion.group.all_discussions(user).map(&:id).uniq,
      conditions: ["updated_at > ?", starting_discussion.updated_at])
    next_discussion.nil? ? starting_discussion : next_discussion
  end
  
  def previous_discussion(starting_discussion, user)
    previous_discussion = Discussion.find(:last, 
      starting_discussion.group.all_discussions(user).map(&:id).uniq,
      conditions: ["updated_at < ?", starting_discussion.updated_at])
    previous_discussion.nil? ? starting_discussion : previous_discussion
  end
  
  def next_unread_discussion(user)
    unread_discussion_found = false
    next_discussion = next_discussion(self, user)
    next_unread_discussion = next_discussion
    last_discussion = self.group.all_discussions(user).first
    
    until (unread_discussion_found)
      if (next_unread_discussion.has_activity_unread_by?(user))
        unread_discussion_found = true
      elsif (next_unread_discussion.id == last_discussion.id)
        break
      else 
        next_unread_discussion = next_discussion(next_unread_discussion, user)
      end
    end
    
    unread_discussion_found ? next_unread_discussion : next_discussion
  end

  def previous_unread_discussion(user)
    unread_discussion_found = false
    previous_discussion = previous_discussion(self, user)
    previous_unread_discussion = previous_discussion
    first_discussion = self.group.all_discussions(user).last
    
    until (unread_discussion_found)
      if (previous_unread_discussion.has_activity_unread_by?(user))
        unread_discussion_found = true
      elsif (previous_unread_discussion.id == first_discussion.id)
        break
      else 
        previous_unread_discussion = previous_discussion(previous_unread_discussion, user)
      end
    end
    
    unread_discussion_found ? previous_unread_discussion : previous_discussion
  end

  def latest_history_time
    if history.count > 0
      history.first.created_at
    else
      created_at
    end
  end
end
