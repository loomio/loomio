class DestroyUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    User.find_by!(id: user_id).destroy!
  end
end
