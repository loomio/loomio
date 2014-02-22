class VoteCache
  attr_accessor :user
  attr_accessor :motions

  def initialize(user, votes)
    @user = user
    @votes = votes
    @votes_by_motion_id = {}
    @votes.each do |vote|
      @votes_by_motion_id[vote.motion_id] = vote
    end
  end

  def get_for(motion)
    @votes_by_motion_id.fetch(motion.id) { Vote.new(motion: motion, user: user) }
  end
end
