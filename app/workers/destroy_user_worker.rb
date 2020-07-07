class DestroyUserWorker
  include Sidekiq::Worker

  def perform(user_id)
    ActiveRecord::Base.transaction do
      User.find(user_id).destroy!
      Ahoy::Message.where(user_id: user_id).delete_all
      Ahoy::Visit.where(user_id: user_id).delete_all
      Ahoy::Event.where(user_id: user_id).delete_all
    end
  end
end
