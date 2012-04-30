class Discussion < ActiveRecord::Base
  class AuthorValidator < ActiveModel::Validator
    def validate(record)
      unless record.group.users.include? record.author
        record.errors[:author] << 'must be a member of the discussion group'
      end
    end
  end

  acts_as_commentable

  belongs_to :group
  belongs_to :author, class_name: 'User'
  has_many :motions

  validates_with AuthorValidator

  def add_comment(user, comment)
    if can_be_commented_on_by? user
      comment = Comment.build_from self, user.id, comment
      comment.save
      comment
    end
  end

  def default_motion
    motions.first
  end

  def can_be_commented_on_by?(user)
    group.users.include? user
  end

  def default_motion
    motions.first
  end

  def update_activity
    self.activity += 1
    save
  end

  def comments
    comment_threads.order("created_at DESC")
  end
end
