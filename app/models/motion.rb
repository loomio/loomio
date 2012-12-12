class Motion < ActiveRecord::Base
  PHASES = %w[voting closed]

  belongs_to :author, :class_name => 'User'
  belongs_to :discussion
  has_many :votes, :dependent => :destroy
  has_many :did_not_votes, :dependent => :destroy
  has_many :events, :as => :eventable, :dependent => :destroy

  validates_presence_of :name, :discussion, :author 
  validates_inclusion_of :phase, in: PHASES
  validates_format_of :discussion_url, with: /^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i,
    allow_blank: true

  validates_length_of :name, :maximum => 250
  validates_length_of :outcome, :maximum => 250

  delegate :email, :to => :author, :prefix => :author
  delegate :name, :to => :author, :prefix => :author
  delegate :group, :to => :discussion
  delegate :users, :full_name, :to => :group, :prefix => :group
  delegate :email_new_motion?, to: :group, prefix: :group

  after_create :initialize_discussion
  after_create :fire_new_motion_event
  before_save :set_disable_discussion
  before_save :format_discussion_url

  attr_accessor :create_discussion
  attr_accessor :enable_discussion

  attr_accessible :name, :description, :discussion_url, :enable_discussion 
  attr_accessible :close_date, :phase, :discussion_id, :outcome

  include AASM
  aasm :column => :phase do
    state :voting, :initial => true
    state :closed

    event :open_voting, before: :before_open do
      transitions :to => :voting, :from => [:closed]
    end

    event :close_voting, before: :before_close, after: :after_close do
      transitions :to => :closed, :from => [:voting]
    end
  end

  scope :voting_sorted, voting.order('close_date ASC')
  scope :closed_sorted, closed.order('close_date DESC')

  scope :that_user_has_voted_on, lambda {|user|
    joins(:votes)
    .where("votes.user_id = ?", user.id)
  }

  def group_users_without_motion_author
    group.users.where(User.arel_table[:id].not_eq(author.id))
  end

  def user_has_voted?(user)
    votes.map{|v| v.user.id}.include?(user.id)
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

  def votes_graph_ready
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
      if v.position == "block"
        return true
      end
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

  def open_close_motion
    if (close_date && close_date <= Time.now)
      if voting?
        close_voting
        save
      end
    elsif closed?
      open_voting
      save
    end
  end

  def has_close_date?
    close_date != nil
  end

  def no_vote_count
    if voting?
      group_count - unique_votes.count
    else
      did_not_votes.count
    end
  end

  def percent_voted
    (100-(no_vote_count/group_count.to_f * 100)).to_i
  end

  def users_who_did_not_vote
    if voting?
      users = []
      group.users.each do |user|
        users << user unless user_has_voted?(user)
      end
      users
    else
      did_not_votes.map{ |did_not_vote| did_not_vote.user }
    end
  end

  def group_count
    if voting?
      group.users.count
    else
      unique_votes.count + no_vote_count
    end
  end

  def group_members
    group.users
  end

  def update_discussion_activity
    discussion.update_activity if discussion
  end

  def number_of_votes_since_last_looked(user)
    if user && user.is_group_member?(group)
      last_viewed_at = last_looked_at_by(user)
      if last_viewed_at 
        return number_of_votes_since(last_viewed_at)
      end
    end
    unique_votes.count
  end

  def last_looked_at_by(user)
    motion_read_log = MotionReadLog.where('motion_id = ? AND user_id = ?',
      id, user.id).first
    if motion_read_log
      return motion_read_log.motion_last_viewed_at
    end
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
    if votes.count > 0
      votes.order('created_at DESC').first.created_at
    else
      created_at
    end
  end

  def set_outcome(str)
    if closed?
      self.outcome = str
      save
    end
  end 

  private
    def fire_new_motion_event
      Event.new_motion!(self)
    end

    def before_open
      self.close_date = Time.now + 1.week
      did_not_votes.each do |did_not_vote|
        did_not_vote.delete
      end
    end

    def before_close
      store_users_that_didnt_vote
      self.close_date = Time.now
    end

    def after_close
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

    def set_disable_discussion
      if @enable_discussion
        self.disable_discussion = @enable_discussion == "1" ? "0" : "1"
      end
    end
end
