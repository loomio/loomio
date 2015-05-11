class Motion < ActiveRecord::Base
  CHART_COLOURS = ["#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc']

  include ReadableUnguessableUrls
  include HasTimeframe

  belongs_to :author, class_name: 'User'
  belongs_to :user, foreign_key: 'author_id' # duplicate author relationship for eager loading
  belongs_to :outcome_author, class_name: 'User'
  belongs_to :discussion, counter_cache: true
  # has_one :group, through: :discussion
  has_many :votes,         -> { includes(:user) },  dependent: :destroy
  has_many :unique_votes,  -> { includes(:user).where(age: 0) }, class_name: 'Vote'
  has_many :did_not_votes, -> { includes(:user) }, dependent: :destroy
  has_many :did_not_voters, through: :did_not_votes, source: :user
  has_many :events,        -> { includes(:eventable) }, as: :eventable, dependent: :destroy
  has_many :motion_readers, dependent: :destroy

  validates_presence_of :name, :discussion, :author, :closing_at

  validates_length_of :name, maximum: 250

  include Translatable
  is_translatable on: [:name, :description]

  include PgSearch
  pg_search_scope :search, against: [:name, :description],
    using: {tsearch: {dictionary: "english"}}

  delegate :email, to: :author, prefix: :author
  delegate :name, to: :author, prefix: :author
  delegate :group, :group_id, to: :discussion
  delegate :members, :full_name, to: :group, prefix: :group
  delegate :email_new_motion?, to: :group, prefix: :group
  delegate :name_and_email, to: :user, prefix: :author
  delegate :locale, to: :user
  delegate :followers, to: :discussion
  delegate :title, to: :discussion, prefix: :discussion
  has_paper_trail only: [:name, :description, :closing_at]

  after_initialize :set_default_closing_at

  attr_accessor :create_discussion

  scope :voting,                   -> { where(closed_at: nil).order(closed_at: :asc) }
  scope :lapsed,                   -> { where('closing_at < ?', Time.now) }
  scope :lapsed_but_not_closed,    -> { voting.lapsed }
  scope :closed,                   -> { where('closed_at IS NOT NULL').order(closed_at: :desc) }
  scope :order_by_latest_activity, -> { order('last_vote_at desc') }
  #scope :visible_to_public,        -> { joins(:discussion).merge(Discussion.public) }
  scope :voting_or_closed_after,   ->(time) { where('motions.closed_at IS NULL OR (motions.closed_at > ?)', time) }
  scope :closing_in_24_hours,      -> { where('motions.closing_at > ? AND motions.closing_at <= ?', Time.now, 24.hours.from_now) }
  scope :chronologically, -> { order('created_at asc') }


  def proposal_title
    name
  end

  def has_outcome?
    outcome.present?
  end

  def grouped_unique_votes
    order = ['block', 'no', 'abstain', 'yes']
    unique_votes.sort do |a,b|
      order.index(a.position) <=> order.index(b.position)
    end
  end

  def title
    name
  end

  def user
    author
  end

  def voters
    votes.map(&:user).uniq.compact
  end

  def voter_ids
    votes.pluck(:user_id).uniq.compact
  end

  def voting?
    closed_at.nil?
  end

  def closed?
    closed_at.present?
  end

  def has_votes?
    total_votes_count > 0
  end

  def discussion_key
    discussion.key
  end

  # map of position and votes
  def vote_counts
    {'yes' => yes_votes_count,
     'abstain' => abstain_votes_count,
     'no' => no_votes_count,
     'block' => block_votes_count}
  end

  def restricted_changes_made?
    (changed & ['name', 'description']).any?
  end

  def can_be_edited?
    !persisted? || (voting? && (!has_votes? || group.motions_can_be_edited?))
  end

  # number of final votes
  def total_votes_count
    vote_counts.values.sum
  end

  # number of vote records - ie: including changes to votes
  # not to be confused with vote_counts (which is why we call it activity_count)
  def activity_count
    votes_count
  end

  # depricated
  def votes_for_graph
    votes_for_graph = []
    vote_counts.each do |k, v|
      votes_for_graph.push ["#{k.capitalize} (#{v})", v, "#{k.capitalize}", ([1]*v)]
    end
    if activity_count == 0
      votes_for_graph.push ["Yet to vote (#{members_not_voted_count})", members_not_voted_count, 'Yet to vote', ([1]*members_not_voted_count)]
    end
    votes_for_graph
  end

  def user_has_voted?(user)
    return false if user.nil?
    votes.for_user(user.id).exists?
  end

  def user_has_not_voted?(user)
    !user_has_voted?(user)
  end

  def most_recent_vote_of(user)
    votes.for_user(user.id).last
  end

  def can_be_voted_on_by?(user)
    user && group.users.include?(user)
  end

  def last_vote_by_user(user)
    return nil if user.nil?

    votes.where(user_id: user.id, age: 0).first
  end

  def last_position_by_user(user)
    if vote = last_vote_by_user(user)
      vote.position
    else
      'unvoted'
    end
  end

  def group_size_when_voting
    if voting?
      group.memberships_count
    else
      total_votes_count + members_not_voted_count
    end
  end

  def members_not_voted
    if voting?
      group_members - voters
    else
      did_not_voters
    end
  end

  def members_not_voted_count
    if voting?
      group_members.size - total_votes_count
    else
      did_not_votes_count
    end
  end

  def percent_voted
    if group_size_when_voting == 0
      0
    else
      (100-(members_not_voted_count/group_size_when_voting.to_f * 100)).to_i
    end
  end

  # recount all the final votes.
  # rather expensive
  def update_vote_counts!
    position_counts = {}

    Vote::POSITIONS.each do |position|
      position_counts[position] = 0
    end

    unique_votes.each do |vote|
      position_counts[vote.position] += 1
    end

    Vote::POSITIONS.each do |position|
      self.send("#{position}_votes_count=", position_counts[position])
    end

    # set the activity count
    self[:votes_count] = votes.count

    save!
  end

  def group_members_without_motion_author
    group.members.without(author)
  end

  def group_members_without_outcome_author
    group.members.without(outcome_author)
  end

  def store_users_that_didnt_vote
    did_not_votes.delete_all
    group.users.each do |user|
      unless user_has_voted?(user)
        did_not_vote = DidNotVote.new
        did_not_vote.user = user
        did_not_vote.motion = self
        did_not_vote.save
      end
    end
    update_attribute(:did_not_votes_count, did_not_votes.count)
    reload
  end

  private
    def one_motion_voting_at_a_time
      if voting? and discussion.current_motion.present? and discussion.current_motion != self
        errors.add(:discussion, 'already has a motion in progress')
      end
    end

  def set_default_closing_at
    self.closing_at ||= (Time.zone.now + 3.days).at_beginning_of_hour
  end
end
