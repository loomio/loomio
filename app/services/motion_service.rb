class MotionService
  def self.create_outcome(motion, motion_params, user)
    user.ability.authorize! :create_outcome, motion

    return false unless motion.update_attribute(:outcome, motion_params[:outcome])

    Events::MotionOutcomeCreated.publish!(motion, user)
  end

  def self.update_outcome(motion, motion_params, user)
    user.ability.authorize! :update_outcome, motion

    return false unless motion.update_attribute(:outcome, motion_params[:outcome])

    Events::MotionOutcomeUpdated.publish!(motion, user)
  end
end