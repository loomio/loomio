class Motion < ActiveRecord::Base
  #PHASES = %w[discussion voting closed]
  PHASES = %w[voting closed]

  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  has_many :votes
  validates_presence_of :name, :group, :author, :facilitator_id
  validates_inclusion_of :phase, in: PHASES

  include AASM
  aasm :column => :phase do
    state :voting, :initial => true
    state :closed

    event :open_voting, :after => :clear_no_vote_count do
      transitions :to => :voting, :from => [:voting, :closed]
    end

    event :close_voting, :after => :store_no_vote_count do
      transitions :to => :closed, :from => [:voting]
    end
  end

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
    Vote::POSITIONS.map {|position|
      [position, votes.where(:position => position)]
    }.to_hash
  end

  # Craig: This method seems too big, suggest refactoring (Extract Method).
  def votes_graph_ready
    votes_for_graph = []
    votes_breakdown.each do |k, v|
      votes_for_graph.push ["#{k.capitalize} (#{v.size})", v.size, "#{k.capitalize}", [v.map{|v| v.user.email}]]
    end
    yet_to_vote_count = calculate_no_vote_count
    text = "Yet to vote "
    if (closed?)
      text = "Did not vote "
      yet_to_vote_count = no_vote_count
    end
    votes_for_graph.push [text + "(#{yet_to_vote_count})", yet_to_vote_count, 'Yet to vote', [group.users.map{|u| u.email unless votes.where('user_id = ?', u).exists?}.compact!]]
    return votes_for_graph
  end

  private

    def store_no_vote_count
      self.no_vote_count = calculate_no_vote_count
    end

    def calculate_no_vote_count
      group.memberships.size - votes.size
    end

    def clear_no_vote_count
      self.no_vote_count = nil
    end
end
