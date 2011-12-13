class Motion < ActiveRecord::Base
  PHASES = %w[discussion voting closed]
  belongs_to :group
  belongs_to :author, :class_name => 'User'
  belongs_to :facilitator, :class_name => 'User'
  has_many :votes
  validates_presence_of :name, :group, :author,
                        :phase, :facilitator_id
  validates_inclusion_of :phase, in: PHASES

  scope :discussing, where(:phase == 'discussion')
  scope :voting, where(:phase == 'voting')
  scope :closed, where(:phase == 'closed')

  def user_has_voted?(user)
    self.votes.map{|v| v.user.id}.include? user.id
  end

  def votes_breakdown
    return @votes = {
      'yes' => self.votes.where('position = ?', 'yes'),
      'no' => self.votes.where('position = ?', 'no'),
      'abstain' => self.votes.where('position = ?', 'abstain'),
      'block' =>  self.votes.where('position = ?', 'block')
    }
  end

  def votes_graph_ready
    @votes_for_graph = []
    self.votes_breakdown.each do |k, v|
      @votes_for_graph.push ["#{k.capitalize} (#{v.size})", v.size, "#{k.capitalize}", [v.map{|v| v.user.email}]]
    end
    @yet_to_vote = self.group.memberships.size - self.votes.size
    @votes_for_graph.push ["Yet to vote (#{@yet_to_vote})", @yet_to_vote, 'Yet to vote', [self.group.users.map{|u| u.email unless self.votes.where('user_id = ?', u).exists?}.compact!]]
    return @votes_for_graph
  end
end
