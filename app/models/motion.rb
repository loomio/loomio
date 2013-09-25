class Motion < ActiveRecord::Base
  CHART_COLOURS = ["#90D490", "#F0BB67", "#D49090", "#dd0000", '#ccc']

  belongs_to :author, :class_name => 'User'
  belongs_to :discussion
  has_many :votes, :dependent => :destroy
  has_many :did_not_votes, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy
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
  delegate :users, :full_name, :to => :group, :prefix => :group
  delegate :email_new_motion?, to: :group, prefix: :group

  after_initialize :set_default_close_at_date_and_time
  before_validation :set_closing_at
  after_create :fire_new_motion_event

  attr_accessor :create_discussion

  scope :voting, where('closed_at IS NULL').order('closed_at ASC')
  scope :closed, where('closed_at IS NOT NULL').order('closed_at DESC')
  scope :that_user_has_voted_on, lambda {|user|
    joins(:votes).where("votes.user_id = ?", user.id)
  }
  scope :order_by_latest_activity, -> { order('last_vote_at desc') }

  def title
    name
  end

  def user
    author
  end

  def voting?
    closed_at.nil?
  end

  def closed?
    closed_at.present?
  end

  def close!(user=nil)
    store_users_that_didnt_vote
    self.closed_at = Time.now
    save!
    fire_motion_closed_event(user)
  end

  def close_if_expired
    close! if closing_at <= Time.now
  end

  def set_outcome!(str)
    if closed?
      self.outcome = str
      save
    end
  end

  def as_read_by(user)
    if user.blank?
      self.motion_readers.build(motion: self)
    else
      find_or_new_motion_reader_for(user)
    end
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
    votes.for_user(user).exists?
  end

  def can_be_voted_on_by?(user)
    user && group.users.include?(user)
  end

  def vote!(user, position, statement=nil)
    vote = user.votes.new(:position => position, :statement => statement)
    vote.motion = self
    vote.save!
    vote
  end

  def latest_vote_time
    if last_vote_at.present?
      last_vote_at
    else
      # this seems incorrect behaviour
      # and without it this method could be removed
      created_at
    end
  end

  def last_vote_by_user(user)
    votes.where(user_id: user.id).order('created_at DESC').first
  end

  def last_position_by_user(user)
    if vote = last_vote_by_user(user)
      vote.position
    else
      nil
    end
  end

  # members_not_voted_count
  # was no_vote_count
  def members_not_voted_count
    if voting?
      group_size_when_voting - total_votes_count
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

    Vote.unique_votes(self).each do |vote|
      position_counts[vote.position] += 1
    end

    Vote::POSITIONS.each do |position|
      self.send("#{position}_votes_count=", position_counts[position])
    end

    # set the activity count
    self[:votes_count] = votes.count

    save!
  end

  def group_size_when_voting
    if voting?
      group.memberships_count || 0
    else
      total_votes_count + members_not_voted_count
    end
  end

  # todo: move to motion mover service
  def move_to_group(group)
    if discussion.present?
      discussion.group = group
      discussion.save
    end
  end

  def group_users_without_motion_author
    group.users.where(User.arel_table[:id].not_eq(author.id))
  end

  #expensive to call
  def unique_votes
    Vote.unique_votes(self)
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

    def fire_motion_closed_event(user)
      Events::MotionClosed.publish!(self, user)
    end

    def store_users_that_didnt_vote
      did_not_votes.each do |did_not_vote|
        did_not_vote.delete
      end
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
end
