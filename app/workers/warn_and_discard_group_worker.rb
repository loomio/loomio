class WarnAndDiscardGroupWorker < ApplicationJob
  queue_as :low

  def perform(group_id)
    return unless ENV["CLEANUP_ENABLED"].present?

    group = Group.kept.find_by(id: group_id)
    return unless group

    Group.transaction(requires_new: true) do |transaction|
      group.lock!
      group.discard!(actor: nil)
      transaction.after_commit do
        group.admins.each do |admin|
          GroupMailer.expired_trial_deletion_warning(group.id, admin.id).deliver_later
        end
        Sentry.metrics.count("group.destroy", attributes: { reason: CleanupService::EXPIRED_TRIAL_REASON })
        EventBus.broadcast("group_destroy", group, nil)
      end
    end
  end
end
