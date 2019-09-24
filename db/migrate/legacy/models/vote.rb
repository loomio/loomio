class Vote < ApplicationRecord
  POSITIONS = %w[yes abstain no block]
  default_scope { includes(:previous_vote) }
  belongs_to :motion, counter_cache: true, touch: :last_vote_at
  belongs_to :user
  belongs_to :previous_vote, class_name: 'Vote'
  has_many :events, as: :eventable, dependent: :destroy

  has_one :discussion, through: :motion
  has_one :group, through: :discussion

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_length_of :statement, maximum: 250

  scope :for_user,      -> (user_id) { where(user_id: user_id) }
  scope :most_recent,   -> { where(age: 0) }

  delegate :name, to: :user, prefix: :user # deprecated
  delegate :name, to: :user, prefix: :author
  delegate :users, to: :group, prefix: :group
  delegate :author, to: :motion, prefix: :motion
  delegate :author, to: :discussion, prefix: :discussion
  delegate :name, to: :motion, prefix: :motion
  delegate :name, :full_name, to: :group, prefix: :group
  delegate :locale, to: :user
  delegate :title, to: :discussion, prefix: :discussion
  delegate :key, to: :motion

  before_create :age_previous_votes, :associate_previous_vote

  after_create :update_motion_vote_counts
  after_destroy :update_motion_vote_counts

  # alias_method does not work for the following obvious methods
  def author=(obj)
    self.user = obj
  end

  def proposal_id
    motion_id
  end

  def group_id
    group&.id
  end

  def discussion_id
    discussion&.id
  end

  def proposal_id=(id)
    self.motion_id=id
  end

  def proposal
    motion
  end

  def proposal=(obj)
    self.motion = obj
  end

  def author
    user
  end

  def position_verb
    case position
    when 'yes' then 'agree'
    when 'no' then 'disagree'
    when 'abstain' then 'abstain'
    when 'block' then 'block'
    end
  end

  def position_to_s
    return I18n.t(self.position, scope: [:position_verbs, :past_tense])
  end

  def previous_position
    previous_vote.position if previous_vote
  end

  private

  def associate_previous_vote
    self.previous_vote = motion.votes.where(user_id: user_id, age: age + 1).first
  end

  def age_previous_votes
    raise "only for new votes" if persisted?
    Vote.transaction do
      motion.votes.where(user_id: user_id).order('age desc').each do |vote|
        vote.update_attribute(:age, vote.age + 1)
      end
    end
    #motion.votes.where(user_id: user_id).update_all('age = age + 1')
  end

  def update_motion_vote_counts
    unless motion.nil? || motion.discussion.nil?
      motion.update_vote_counts!
    end
  end
end
