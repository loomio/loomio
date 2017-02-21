class MotionService
  def self.create(motion:, actor:)
    actor.ability.authorize! :create, motion
    motion.author = actor
    return false unless motion.valid?
    motion.save!

    EventBus.broadcast('motion_create', motion, actor)
    Events::NewMotion.publish!(motion)
  end

  def self.update(motion:, params:, actor:)
    close(motion) if motion.needs_to_be_closed?
    actor.ability.authorize! :update, motion

    if params[:closing_at] && motion.closing_at.to_s == Time.zone.parse(params[:closing_at]).to_s
      params.delete(:closing_at)
    end

    motion.assign_attributes(params)
    return false unless motion.valid?

    motion.save!
    EventBus.broadcast('motion_update', motion, actor)
    Events::MotionEdited.publish!(motion, actor)
  end

  def self.close_all_lapsed_motions
    Motion.lapsed_but_not_closed.each { |motion| close(motion) }
  end

  def self.reopen(motion, close_at)
    motion.closed_at = nil
    motion.closing_at = close_at
    motion.save!
    motion.did_not_votes.delete_all
    EventBus.broadcast('motion_reopen', motion, close_at)
  end

  def self.close(motion)
    motion.close!
    EventBus.broadcast('motion_close', motion)
    Events::MotionClosed.publish!(motion)
  end

  def self.close_by_user(motion, user)
    user.ability.authorize! :close, motion
    motion.close!
    EventBus.broadcast('motion_close_by_user', motion, user)
    Events::MotionClosedByUser.publish!(motion, user)
  end

  def self.create_outcome(motion:, params:, actor:)
    close(motion) if motion.needs_to_be_closed?
    motion.outcome_author = actor
    actor.ability.authorize! :create_outcome, motion

    motion.assign_attributes(params.slice(:outcome))
    return false unless motion.valid?

    motion.save!
    EventBus.broadcast('motion_create_outcome', motion, params, actor)
    Events::MotionOutcomeCreated.publish!(motion)
  end

  def self.update_outcome(motion:, params:, actor:)
    close(motion) if motion.needs_to_be_closed?
    motion.outcome_author = actor
    actor.ability.authorize! :update_outcome, motion

    motion.assign_attributes(params.slice(:outcome))
    return false unless motion.valid?

    motion.save!
    EventBus.broadcast('motion_update_outcome', motion, params, actor)
    Events::MotionOutcomeUpdated.publish!(motion, actor)
  end
end
