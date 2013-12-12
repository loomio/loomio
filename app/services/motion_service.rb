class MotionService
  def self.close_all_lapsed_motions
    Motion.lapsed_but_not_closed.each do |motion|
      close(motion)
    end
  rescue Exception => e
    # why the fart won't heroku let us know a cronjob failed?
    ExceptionNotifier.notify_exception(
      UnacceptableMotionError.new(motion, e),
      env: request.env
    )
  end

  def self.close(motion)
    # this line is required because motions are not being
    # archived when groups get archived so they dangle
    # TODO ensure that motions get archived with groups
    return false unless motion.group.present?

    motion.store_users_that_didnt_vote
    motion.closed_at = Time.now
      motion.save!

    Events::MotionClosed.publish!(motion)
  end

  def self.close_by_user(motion, user)
    return false unless motion.group.present?

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

  class UnacceptableMotionError < StandardError
    def initialize(motion, exception)
      @motion = motion
      @exception = exception
    end

    def message
      "Motion close cron job failed. This is going to fuck up
       all the motions waiting to close for ever until fixed,
       so fix immediately, Jesus/Jesse.
       #{motion.inspect} #{exception.inspect}"
    end
  end
end
