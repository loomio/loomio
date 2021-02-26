class DestroyGroupWorker
  include Sidekiq::Worker

  def perform(group_id)
    Group.archived.find(group_id).try(:destroy!)
  end
end
