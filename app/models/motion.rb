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
    votes.map{|v| v.user.id}.include? user.id
  end

  def phase=(new_phase)
    if new_phase == 'closed'
      unless phase == 'closed'
        self.no_vote_count = group.memberships.size - votes.size
      end
    else
      self.no_vote_count = nil
    end
    self[:phase] = new_phase
  end

  def open_voting
    phase = 'voting'
  end

  def close_voting
    phase = 'closed'
  end

  def with_votes
    if votes.size > 0
      votes
    end
  end

  def votes_breakdown
    return {
      'yes' => votes.where('position = ?', 'yes'),
      'no' => votes.where('position = ?', 'no'),
      'abstain' => votes.where('position = ?', 'abstain'),
      'block' => votes.where('position = ?', 'block')
    }
  end

  # Craig: This method seems too big, suggest refactoring (Extract Method).
  def votes_graph_ready
    votes_for_graph = []
    votes_breakdown.each do |k, v|
      votes_for_graph.push ["#{k.capitalize} (#{v.size})", v.size, "#{k.capitalize}", [v.map{|v| v.user.email}]]
    end
    yet_to_vote_count = group.memberships.size - votes.size
    text = "Yet to vote "
    if (phase == 'closed')
      text = "Did not vote "
      yet_to_vote_count = no_vote_count
    end
    votes_for_graph.push [text + "(#{yet_to_vote_count})", yet_to_vote_count, 'Yet to vote', [group.users.map{|u| u.email unless votes.where('user_id = ?', u).exists?}.compact!]]
    return votes_for_graph
  end

  private

    def set_defaults
      self.phase ||= 'voting'
    end
end
