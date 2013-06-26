class Motion < ActiveRecord::Base
  PHASES = %w[voting closed]

  belongs_to :author, :class_name => 'User'
  belongs_to :discussion
  has_many :votes, :dependent => :destroy
  has_many :did_not_votes, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy

  has_paper_trail

  validates_presence_of :name, :discussion, :author, :close_at
  validates_inclusion_of :phase, in: PHASES
  validates_format_of :discussion_url, with: /^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i,
    allow_blank: true

  validates_length_of :name, :maximum => 250
  validates_length_of :outcome, :maximum => 250

  delegate :email, :to => :author, :prefix => :author
  delegate :name, :to => :author, :prefix => :author
  delegate :group, :group_id, :to => :discussion
  delegate :users, :full_name, :to => :group, :prefix => :group
  delegate :email_new_motion?, to: :group, prefix: :group

  before_validation :set_close_at
  before_save :format_discussion_url
  after_save :update_counter_cache
  after_create :initialize_discussion
  after_create :fire_new_motion_event
  after_destroy :update_counter_cache

  attr_accessor :create_discussion

  attr_accessible :name, :description, :discussion_url, :discussion_id
  attr_accessible :close_at_date, :close_at_time, :close_at_time_zone, :phase,  :outcome

  include AASM
  aasm :column => :phase do
    state :voting, :initial => true
    state :closed

    event :close, before: :before_close do
      transitions :to => :closed, :from => [:voting]
    end
  end

  scope :voting_sorted, voting.order('close_at ASC')
  scope :closed_sorted, closed.order('close_at DESC')

  scope :that_user_has_voted_on, lambda {|user|
    joins(:votes).where("votes.user_id = ?", user.id)
  }

  def group_users_without_motion_author
    group.users.where(User.arel_table[:id].not_eq(author.id))
  end

  def with_votes
    votes if votes.size > 0
  end

  def unique_votes
    Vote.unique_votes(self)
  end

  def votes_breakdown
    last_votes = unique_votes()
    positions = Array.new(Vote::POSITIONS)
    positions.delete("did_not_vote")
    positions.map {|position|
      [position, last_votes.find_all{|vote| vote.position == position}]
    }.to_hash
  end

  def votes_for_graph
    votes_for_graph = []
    votes_breakdown.each do |k, v|
      votes_for_graph.push ["#{k.capitalize} (#{v.size})", v.size, "#{k.capitalize}", [v.map{|b| b.user.email}]]
    end
    if votes.size == 0
      votes_for_graph.push ["Yet to vote (#{no_vote_count})", no_vote_count, 'Yet to vote', [group.users.map{|u| u.email unless votes.where('user_id = ?', u).exists?}.compact!]]
    end
    return votes_for_graph
  end

  def blocked?
    unique_votes.each do |v|
      return true if v.position == "block"
    end
    false
  end

  def user_has_voted?(user)
    votes.for_user(user).exists?
  end

  def can_be_voted_on_by?(user)
    user && group.users.include?(user)
  end

  def move_to_group(group)
    if discussion.present?
      discussion.group = group
      discussion.save
    end
  end

  def unique_votes
    Vote.unique_votes(self)
  end

  # motion is closed by user
  def close_motion!(user=nil)
    close!
    save!
    fire_motion_closed_event(user)
  end

  def close_if_expired
    close_motion! if (voting? && close_at && close_at <= Time.now)
  end

  def set_outcome!(str)
    if closed?
      self.outcome = str
      save
    end
  end

  def has_close_date?
    close_at != nil
  end

  def no_vote_count
    return group_count - unique_votes.count if voting?
    did_not_votes.count
  end

  def percent_voted
    (100-(no_vote_count/group_count.to_f * 100)).to_i
  end

  def group_count
    return group.users.count if voting?
    unique_votes.count + no_vote_count
  end

  def group_members
    group.users
  end

  def update_discussion_activity
    discussion.update_activity if discussion
  end

  def read_log_for(user)
    MotionReadLog.where('motion_id = ? AND user_id = ?',
      id, user.id).first
  end

  def number_of_votes_since_last_looked(user)
    if user
      return number_of_votes_since(last_looked_at_by(user)) if last_looked_at_by(user)
    end
    unique_votes.count
  end

  def last_looked_at_by(user)
    read_log_for(user).motion_last_viewed_at if read_log_for(user)
  end

  def number_of_votes_since(time)
    votes.where('votes.created_at > ?', time).count
  end

  def comments
    discussion.comments
  end

  def vote!(user, position, statement=nil)
    vote = user.votes.new(:position => position, :statement => statement)
    vote.motion = self
    vote.save!
    vote
  end

  def latest_vote_time
    return votes.order('created_at DESC').first.created_at if votes.count > 0
    created_at
  end

  def set_default_close_at_date_and_time
    self.close_at_date ||= 3.days.from_now.to_date
    self.close_at_time ||= Time.now.strftime("%H:00")
  end

  def has_revisions?
    versions.count > 1
  end

  def self.get_editor(editor_id)
    User.find(editor_id)
  end

  private

    def set_close_at
      date_time_zone_format = '%Y-%m-%d %H:%M %Z'
      tz_offset = ActiveSupport::TimeZone[close_at_time_zone].formatted_offset
      date_time_zone_string = "#{close_at_date.to_s} #{close_at_time} #{tz_offset}"
      self.close_at = DateTime.strptime(date_time_zone_string, date_time_zone_format)
    end

    def fire_new_motion_event
      Events::NewMotion.publish!(self)
    end

    def fire_motion_closed_event(user)
      Events::MotionClosed.publish!(self, user)
    end

    def before_close
      store_users_that_didnt_vote
      self.close_at = Time.now
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
      reload
    end

    def initialize_discussion
      unless discussion
        self.discussion = Discussion.new(group: group)
        discussion.author = author
        discussion.title = name
        discussion.save
        save
      end
    end

    def format_discussion_url
      unless self.discussion_url.match(/^http/) || self.discussion_url.empty?
        self.discussion_url = "http://" + self.discussion_url
      end
    end

    def update_counter_cache
      group.update_attribute(:motions_count, group.motions.count)
    end
end
