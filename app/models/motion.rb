class Motion < ActiveRecord::Base
  PHASES = %w[voting closed]

  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  belongs_to :discussion
  has_many :votes
  has_many :motion_activity_read_logs

  validates_presence_of :name, :group, :author, :facilitator_id
  validates_inclusion_of :phase, in: PHASES
  validates_format_of :discussion_url, with: /^((http|https):\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/i,
    allow_blank: true

  delegate :email, :to => :author, :prefix => :author
  delegate :email, :to => :facilitator, :prefix => :facilitator

  before_create :initialize_discussion
  after_create :email_motion_created
  before_save :set_disable_discussion
  before_save :format_discussion_url

  attr_accessor :create_discussion
  attr_accessor :enable_discussion


  include AASM
  aasm :column => :phase do
    state :voting, :initial => true
    state :closed

    event :open_voting, :after => :clear_no_vote_count do
      transitions :to => :voting, :from => [:voting, :closed]
    end

    event :close_voting, :after => :store_no_vote_count do
      transitions :to => :closed, :from => [:voting, :closed]
    end
  end

  scope :voting_sorted, voting.order('close_date ASC')
  scope :closed_sorted, closed.order('close_date DESC')

  scope :that_user_has_voted_on, lambda {|user|
    joins(:votes)
    .where('votes.user_id = ?', user.id)
    .having('count(votes.id) > 0')
  }

  scope :that_user_has_not_voted_on, lambda {|user|
    joins(:votes)
    .where('votes.user_id = ?', user.id)
    .having('count(votes.id) = 0')
  }

  def user_has_voted?(user)
    votes.map{|v| v.user.id}.include? user.id
  end

  def with_votes
    votes if votes.size > 0
  end

  def votes_breakdown
    last_votes = Vote.unique_votes(self)
    Vote::POSITIONS.map {|position|
      [position, last_votes.find_all{|vote| vote.position == position}]
    }.to_hash
  end

  def blocked?
    votes.each do |v|
      if v.position == "block"
        return true
      end
    end
    false
  end

  def votes_graph_ready
    votes_for_graph = []
    votes_breakdown.each do |k, v|
      votes_for_graph.push ["#{k.capitalize} (#{v.size})", v.size, "#{k.capitalize}", [v.map{|v| v.user.email}]]
    end
    if votes.size == 0
      votes_for_graph.push ["Yet to vote (#{no_vote_count})", no_vote_count, 'Yet to vote', [group.users.map{|u| u.email unless votes.where('user_id = ?', u).exists?}.compact!]]
    end
    return votes_for_graph
  end

  def has_admin_user?(user)
    group.has_admin_user?(user)
  end

  def user_has_voted?(user)
    votes.for_user(user).exists?
  end

  def can_be_viewed_by?(user)
    user && group.can_be_viewed_by?(user)
  end

  def can_be_edited_by?(user)
    user && (author == user || facilitator == user)
  end

  def can_be_closed_by?(user)
    user && ((author == user || facilitator == user) || has_admin_user?(user))
  end

  def can_be_deleted_by?(user)
    user && (author == user || has_admin_user?(user))
  end

  def can_be_voted_on_by?(user)
    user && group.users.include?(user)
  end

  def open_close_motion
    if close_date && close_date <= Time.now
      if voting?
        close_voting
      end
    else
      open_voting
    end
    save
  end

  def set_close_date(date)
    self.close_date = date
    save
    open_close_motion
  end

  def has_closing_date?
    close_date == nil
  end

  def has_group_user_tag(tag_name)
    has_tag = false
    votes.each do |vote|
      vote.user.group_tags_from(group).each do |tag|
        if tag == tag_name
          return has_tag = true
        end
      end
    end
    return has_tag
  end

  def no_vote_count
    if closed?
      read_attribute(:no_vote_count)
    else
      calculate_no_vote_count
    end
  end

  def group_count
    if voting?
      group.users.count
    else
      calculate_group_count
    end
  end

  def group_members
    group.users
  end

  def update_vote_activity
    self.vote_activity += 1
    save
  end

  def update_discussion_activity
    self.discussion_activity += 1
    save
  end

  def comments
    discussion.comments
  end

  private
    def initialize_discussion
      self.discussion ||= Discussion.create(author_id: author.id, group_id: group.id)
    end

    def email_motion_created
      group.users.each do |user|
        unless author == user
          MotionMailer.new_motion_created(self, user.email).deliver
        end
      end
    end

    def format_discussion_url
      unless self.discussion_url.match(/^http/) || self.discussion_url.empty?
        self.discussion_url = "http://" + self.discussion_url
      end
    end

    def store_no_vote_count
      self.no_vote_count = calculate_no_vote_count
    end

    def calculate_no_vote_count
      group.memberships.size - votes.size
    end

    def calculate_group_count
      votes.count + no_vote_count
    end

    def clear_no_vote_count
      self.no_vote_count = nil
    end

    def set_disable_discussion
      if @enable_discussion
        self.disable_discussion = @enable_discussion == "1" ? "0" : "1"
      end
    end
end
