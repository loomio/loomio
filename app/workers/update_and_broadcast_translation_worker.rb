class UpdateAndBroadcastTranslationWorker < ApplicationJob
  def perform(class_name, record_id)
    TranslationService.update_and_broadcast(class_name, record_id)
  end
end
