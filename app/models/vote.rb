class Vote < ActiveRecord::Base
  class UserCanVoteValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      unless value && object.motion.can_be_voted_on_by?(User.find(value))
        object.errors.add attribute, "does not have permission to vote on motion."
      end
    end
  end

  class ClosableValidator < ActiveModel::EachValidator
    def validate_each(object, attribute, value)
      if object.motion && (not object.motion.voting?)
        object.errors.add attribute,
          "can only be modified while the motion is in voting phase."
      end
    end
  end

  POSITIONS = %w[yes abstain no block]
  default_scope { includes(:previous_vote) }
  belongs_to :motion, counter_cache: true, touch: :last_vote_at
  belongs_to :user
  belongs_to :previous_vote, class_name: 'Vote'  
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_length_of :statement, maximum: 250
  validates :user_id, user_can_vote: true
  validates :position, :statement, closable: true

  include Translatable
  is_translatable on: :statement

  scope :for_user, lambda {|user_id| where(:user_id => user_id)}
  scope :most_recent, -> { where age: 0  }

  delegate :name, :to => :user, :prefix => :user
  delegate :group, :discussion, :to => :motion
  delegate :users, :to => :group, :prefix => :group
  delegate :author, :to => :motion, :prefix => :motion
  delegate :author, :to => :discussion, :prefix => :discussion
  delegate :name, :to => :motion, :prefix => :motion
  delegate :name, :full_name, :to => :group, :prefix => :group
  delegate :locale, :to => :user

  before_create :age_previous_votes, :associate_previous_vote

  after_save :update_motion_vote_counts
  after_destroy :update_motion_vote_counts

  def author
    user
  end

  def other_group_members
    group.users.where(User.arel_table[:id].not_eq(user.id))
  end

  def can_be_edited_by?(current_user)
    current_user && user == current_user
  end

  def position_to_s
    I18n.t(self.position, scope: [:position_verbs, :past_tense])
  end

  def previous_position
    previous_vote.position if previous_vote
  end

  def previous_position_is_block?
    previous_vote.try(:is_block?)
  end

  def is_block?
    position == 'block'
  end

  def has_statement?
    statement.present?
  end

  private
  def associate_previous_vote
    self.previous_vote = motion.votes.where(user_id: user_id, age: age + 1).first
  end

  def age_previous_votes
    motion.votes.where(user_id: user_id).update_all('age = age + 1')
  end

  def update_motion_vote_counts
    unless motion.nil? || motion.discussion.nil?
      motion.update_vote_counts!
    end
  end
end
