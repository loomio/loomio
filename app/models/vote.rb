class Vote < ActiveRecord::Base
  POSITIONS = %w[yes abstain no block]
  default_scope { includes(:previous_vote) }
  belongs_to :motion, counter_cache: true, touch: :last_vote_at
  belongs_to :user
  belongs_to :previous_vote, class_name: 'Vote'
  has_many :events, as: :eventable, dependent: :destroy

  validates_presence_of :motion, :user, :position
  validates_inclusion_of :position, in: POSITIONS
  validates_length_of :statement, maximum: 250

  include Translatable
  is_translatable on: :statement

  include HasTimeframe

  scope :for_user,      -> (user_id) { where(user_id: user_id) }
  scope :by_discussion, -> (discussion_id = nil) { joins(:motion).where("motions.discussion_id = ? OR ? IS NULL", discussion_id, discussion_id) }
  scope :most_recent,   -> { where(age: 0) }
  scope :chronologically, -> { order('created_at asc') }

  delegate :name, to: :user, prefix: :user # deprecated
  delegate :name, to: :user, prefix: :author
  delegate :group, :discussion, to: :motion
  delegate :users, to: :group, prefix: :group
  delegate :author, to: :motion, prefix: :motion
  delegate :author, to: :discussion, prefix: :discussion
  delegate :name, to: :motion, prefix: :motion
  delegate :name, :full_name, to: :group, prefix: :group
  delegate :locale, to: :user
  delegate :discussion_id, to: :motion
  delegate :title, to: :discussion, prefix: :discussion
  delegate :id, to: :group, prefix: :group

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

  def motion_followers_without_voter
    motion.followers.where('users.id != ?', author.id)
  end

  def other_group_members
    group.users.where(User.arel_table[:id].not_eq(user.id))
  end

  def can_be_edited_by?(current_user)
    current_user && user == current_user
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
