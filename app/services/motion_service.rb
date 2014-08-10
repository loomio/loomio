class MotionService
  def self.start_motion(motion)
    motion.author.ability.authorize! :create, motion
    return false unless motion.valid?
    motion.save
    DiscussionReader.for(discussion: motion.discussion, user: motion.author).follow!
    Events::NewMotion.publish!(motion)
  end

  def self.update_motion(motion: motion, params: params, user: user)

    if motion.closing_at.to_s == Time.zone.parse(params[:closing_at]).to_s
      params.delete(:closing_at)
    end

    motion.attributes = params

    user.ability.authorize! :update, motion

    if motion.valid?
      if motion.name_changed?
        Events::MotionNameEdited.publish!(motion, user)
      end

      if motion.description_changed?
        Events::MotionDescriptionEdited.publish!(motion, user)
      end

      if motion.closing_at_changed?
        Events::MotionCloseDateEdited.publish!(motion, user)
      end
      motion.save
    else
      false
    end
  end

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

  def self.reopen(motion, close_at)
    motion.closed_at = nil
    motion.closing_at = close_at
    motion.save!
    motion.did_not_votes.delete_all
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
