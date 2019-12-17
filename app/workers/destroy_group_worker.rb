class DestroyGroupWorker
  include Sidekiq::Worker

  def perform(group_id)
    Group.find_by(id: group_id).destroy!
  end
end
