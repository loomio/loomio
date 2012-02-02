class Motion < ActiveRecord::Base
  #PHASES = %w[discussion voting closed]
  PHASES = %w[voting closed]
  after_initialize :set_defaults

  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  has_many :votes
  validates_presence_of :name, :group, :author, :facilitator_id
  validates_inclusion_of :phase, in: PHASES

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
    self.votes.map{|v| v.user.id}.include? user.id
  end

  def phase=(phase)
    if (phase == 'closed')
      unless (self.phase == 'closed')
        self.no_vote_count = self.group.memberships.size - self.votes.size
      end
    else
      self.no_vote_count = nil
    end
    self[:phase] = phase
  end

  def open_voting
    self.phase = 'voting'
  end

  def close_voting
    self.phase = 'closed'
  end

  def with_votes
    if self.votes.size > 0
      self.votes
    end
  end

  def votes_breakdown
    return votes = {
      'yes' => self.votes.where('position = ?', 'yes'),
      'no' => self.votes.where('position = ?', 'no'),
      'abstain' => self.votes.where('position = ?', 'abstain'),
      'block' =>  self.votes.where('position = ?', 'block')
    }
  end

  def votes_graph_ready
    votes_for_graph = []
    self.votes_breakdown.each do |k, v|
      votes_for_graph.push ["#{k.capitalize} (#{v.size})", v.size, "#{k.capitalize}", [v.map{|v| v.user.email}]]
    end
    no_vote_count = self.group.memberships.size - self.votes.size
    text = "Yet to vote "
    if (self.phase == 'closed')
      text = "Did not vote "
      no_vote_count = self.no_vote_count
    end
    votes_for_graph.push [text + "(#{no_vote_count})", no_vote_count, 'Yet to vote', [self.group.users.map{|u| u.email unless self.votes.where('user_id = ?', u).exists?}.compact!]]
    return votes_for_graph
  end

  private
  def set_defaults
    self.phase ||= 'voting'
  end
end
