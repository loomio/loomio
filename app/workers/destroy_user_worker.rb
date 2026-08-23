class DestroyUserWorker < ApplicationJob
  def perform(user_id)
    ActiveRecord::Base.transaction do
      User.find(user_id).destroy!
    end
  end
end
