class MotionService
  def self.cast_vote(vote)
    vote.user.ability.authorize! :vote, vote.motion

    if vote.save
      if vote.is_block?
        unless vote.previous_position_is_block?
          Events::MotionBlocked.publish!(vote)
        end
      else
        Events::NewVote.publish!(vote)
      end
      true
    end
  end

  def self.close_all_lapsed_motions
    Motion.lapsed_but_not_closed.each do |motion|
      close(motion)
    end
  end

  def self.close(motion)
    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!

    Events::MotionClosed.publish!(motion)
  end

  def self.close_by_user(motion, user)
    user.ability.authorize! :close, motion

    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
    motion.save!

    Events::MotionClosedByUser.publish!(motion, user)
  end

  def self.create_outcome(motion, motion_params, user)
    user.ability.authorize! :create_outcome, motion

    motion.outcome = motion_params[:outcome]
    motion.outcome_author = user
    return false unless motion.save

    Events::MotionOutcomeCreated.publish!(motion, user)
  end

  def self.update_outcome(motion, motion_params, user)
    user.ability.authorize! :update_outcome, motion

    motion.outcome = motion_params[:outcome]
    motion.outcome_author = user
    return false unless motion.save

    Events::MotionOutcomeUpdated.publish!(motion, user)
  end
end
