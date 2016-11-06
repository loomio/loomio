class Votes::Loomio < Vote
  POSITIONS = {
    yes: :agree,
    no:  :disagree,
    abstain: :abstain,
    block: :block
  }.freeze

  after_create :update_vote_counts!
  after_destroy :update_vote_counts!

  validates_inclusion_of :position, in: POSITIONS.keys.map(&:to_s)

  def position_verb
    POSITIONS[self.position]
  end

  def position
    self.stance['position']
  end

  private

  # Hi, this is opaque, sorry.
  # We're taking a default zeroed hash ({yes_votes_count: 0, no_votes_count: 0, etc}),
  # merging it with a hash of our unique vote counts ({ yes_votes_count: 4, block_votes_count: 1}),
  # then updating the motion with those values, plus the total of all votes count.
  # This is a somewhat expensive operation and should be minimized if possible.
  def update_vote_counts!
    return unless motion&.discussion
    motion.update(
      POSITIONS.keys.map { |k| ["#{k}_votes_count", 0] }.to_h
               .merge(motion.reload.unique_votes
                            .group_by { |v| v.stance['position'] }
                            .map { |k,v| ["#{k}_votes_count", v.count] }
                            .to_h)
               .merge(votes_count: motion.unique_votes.count)
   )
  end
end
