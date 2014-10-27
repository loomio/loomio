class VoteService
  def self.cast(vote)
    vote.user.ability.authorize!(:vote, vote.motion)

    if vote.save
      if vote.position == 'block'
        Events::MotionBlocked.publish!(vote)
      else
        Events::NewVote.publish!(vote)
      end
    end
  end
end
