class MotionService
  def self.create(motion:, actor:)
    motion.author = actor
    actor.ability.authorize! :create, motion
    return false unless motion.valid?
    motion.save!

    Draft.purge(user: actor, draftable: motion.discussion, field: :motion)
    SearchVector.index! motion.discussion_id

    event = Events::NewMotion.publish!(motion)
    DiscussionReader.for(discussion: motion.discussion, user: motion.author).author_thread_item!(motion.created_at)
    event
  end

  def self.update(motion:, params:, actor:)

    if params[:closing_at] && motion.closing_at.to_s == Time.zone.parse(params[:closing_at]).to_s
      params.delete(:closing_at)
    end

    motion.attributes = params
    actor.ability.authorize! :update, motion
    return false unless motion.valid?

    motion.save!
    event = Events::MotionEdited.publish!(motion, actor)
    SearchVector.index! motion.discussion_id
    event
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

  def self.create_outcome(motion:, params:, actor:)
    motion.outcome_author = actor
    motion.outcome = params[:outcome]

    return false unless motion.valid?
    actor.ability.authorize! :create_outcome, motion

    motion.save!
    Events::MotionOutcomeCreated.publish!(motion, actor)
  end

  def self.update_outcome(motion:, params:, actor:)
    motion.outcome_author = actor
    motion.outcome = params[:outcome]

    return false unless motion.valid?
    actor.ability.authorize! :update_outcome, motion

    motion.save!
    Events::MotionOutcomeUpdated.publish!(motion, actor)
  end
end
