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
  default_scope include: :previous_vote
  belongs_to :motion, counter_cache: true
  belongs_to :user
  belongs_to :previous_vote, class_name: 'Vote'
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_length_of :statement, maximum: 250
  validates :user_id, user_can_vote: true
  validates :position, :statement, closable: true

  scope :for_user, lambda {|user_id| where(:user_id => user_id)}
  scope :most_recent, -> { where age: 0  }

  delegate :name, :to => :user, :prefix => :user
  delegate :group, :discussion, :to => :motion
  delegate :users, :to => :group, :prefix => :group
  delegate :author, :to => :motion, :prefix => :motion
  delegate :author, :to => :discussion, :prefix => :discussion
  delegate :name, :to => :motion, :prefix => :motion
  delegate :name, :full_name, :to => :group, :prefix => :group

  before_create :age_previous_votes, :associate_previous_vote
  after_save :update_motion_vote_counts, :send_notifications

  after_create :update_motion_last_vote_at, :fire_new_vote_event
  after_destroy :update_motion_last_vote_at, :update_motion_vote_counts

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

  def update_motion_last_vote_at
    unless motion.nil? || motion.discussion.nil?
      motion.last_vote_at = motion.latest_vote_time
      motion.save!
    end
  end

  def fire_new_vote_event
    if position == "block"
      Events::MotionBlocked.publish!(self)
    else
      Events::NewVote.publish!(self)
    end
  end

  def send_notifications
    if position == "block" && previous_vote != "block"
      MotionMailer.delay.motion_blocked(self)
    end
  end
end
