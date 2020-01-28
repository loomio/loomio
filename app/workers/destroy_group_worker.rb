class DestroyGroupWorker
  include Sidekiq::Worker

  def perform(group_id)
    Group.find(group_id).destroy!
  end
end
