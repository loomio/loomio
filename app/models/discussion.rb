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

  # group should be removed if possible - kiesia 8.5.12
  attr_accessible :group, :title

  attr_accessor :comment


  #
  # PERMISSION CHECKS
  #

  def can_be_commented_on_by?(user)
    group.users.include? user
  end

  def can_have_proposal_created_by?(user)
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

  def current_motion
    motions.last
  end

  def history
    (comments + votes).sort_by(&:created_at)
  end

  def update_activity
    self.activity += 1
    save
  end
end
