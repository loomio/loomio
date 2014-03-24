class Motion < ActiveRecord::Base
  CHART_COLOURS = ["#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc']

  include ReadableUnguessableUrls

  belongs_to :author, :class_name => 'User'
  belongs_to :user, foreign_key: 'author_id' # duplicate author relationship for eager loading
  belongs_to :outcome_author, :class_name => 'User'
  belongs_to :discussion
  # has_one :group, through: :discussion
  has_many :votes, :dependent => :destroy, include: :user
  has_many :unique_votes, class_name: 'Vote', conditions: { age: 0 }, include: :user
  has_many :did_not_votes, :dependent => :destroy, include: :user
  has_many :did_not_voters, through: :did_not_votes, source: :user
  has_many :events, :as => :eventable, :dependent => :destroy, include: :eventable
  has_many :motion_readers, dependent: :destroy

  validates_presence_of :name, :discussion, :author, :closing_at

  validates_length_of :name, :maximum => 250
  validates_length_of :outcome, :maximum => 250

  include PgSearch
  pg_search_scope :search, against: [:name, :description],
    using: {tsearch: {dictionary: "english"}}

  delegate :email, :to => :author, :prefix => :author
  delegate :name, :to => :author, :prefix => :author
  delegate :group, :group_id, :to => :discussion
  delegate :members, :full_name, :to => :group, :prefix => :group
  delegate :email_new_motion?, to: :group, prefix: :group
  delegate :name_and_email, to: :user, prefix: :author

  after_initialize :set_default_close_at_date_and_time
  before_validation :set_closing_at
  after_create :fire_new_motion_event

  attr_accessor :create_discussion

  scope :voting, where('motions.closed_at IS NULL').order('motions.closed_at ASC')
  scope :lapsed, lambda { where('closing_at < ?', Time.now) }
  scope :lapsed_but_not_closed, voting.lapsed
  scope :closed, where('closed_at IS NOT NULL').order('motions.closed_at DESC')
  scope :order_by_latest_activity, -> { order('last_vote_at desc') }
  scope :public, joins(:discussion).merge(Discussion.public)

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

  # map of position and votes
  def vote_counts
    {'yes' => yes_votes_count,
     'abstain' => abstain_votes_count,
     'no' => no_votes_count,
     'block' => block_votes_count}
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

  # todo: move to motion mover service
  def move_to_group(group)
    if discussion.present?
      discussion.group = group
      discussion.save
    end
  end

  def group_members_without_motion_author
    group.users.where(User.arel_table[:id].not_eq(author.id))
  end

  def group_members_without_outcome_author
    group.users.where(User.arel_table[:id].not_eq(outcome_author.id))
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
    def find_or_new_motion_reader_for(user)
      if self.motion_readers.where(user_id: user.id).exists?
        self.motion_readers.where(user_id: user.id).first
      else
        motion_reader = self.motion_readers.build
        motion_reader.motion = self
        motion_reader.user = user
        motion_reader
      end
    end

    def set_default_close_at_date_and_time
      self.close_at_date ||= (Time.zone.now + 3.days).to_date
      self.close_at_time ||= Time.zone.now.strftime("%H:00")
    end

    def set_closing_at
      date_time_zone_format = '%Y-%m-%d %H:%M %Z'
      tz_offset = ActiveSupport::TimeZone[close_at_time_zone].formatted_offset
      date_time_zone_string = "#{close_at_date.to_s} #{close_at_time} #{tz_offset}"
      self.closing_at = DateTime.strptime(date_time_zone_string, date_time_zone_format)
    end

    def fire_new_motion_event
      Events::NewMotion.publish!(self)
    end
end
