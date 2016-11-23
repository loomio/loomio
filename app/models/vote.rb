class Vote < ActiveRecord::Base
  belongs_to :motion, counter_cache: true, touch: :last_vote_at
  belongs_to :user
  belongs_to :previous_vote, class_name: 'Vote'
  has_one :discussion, through: :motion
  has_many :events, as: :eventable, dependent: :destroy

  validates_presence_of :motion, :user
  validates_length_of :statement, maximum: 250

  include Translatable
  is_translatable on: :statement

  include HasTimeframe

  scope :for_user,      -> (user_id) { where(user_id: user_id) }
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
  delegate :key, to: :motion
  delegate :kind, to: :motion
  delegate :id, to: :group, prefix: :group

  before_create :age_previous_votes, :associate_previous_vote

  update_counter_cache :motion, :voters_count

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
  end
end
