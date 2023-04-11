class DestroyRecordWorker
  include Sidekiq::Worker
  def perform(class_name, record_id)
  	class_name.constantize.find(record_id).destroy!
  end
end