class PublishTopicModelWorker < ApplicationJob
  # Live updates run outside the request, so a topic with many guests cannot
  # slow down or time out the change that triggered them. The model is loaded
  # when the job runs: a deleted record is skipped, and stance visibility is
  # checked again because results may have been hidden since it was enqueued.
  def perform(model_class_name, model_id)
    model = model_class_name.constantize.find_by(id: model_id)
    return unless model
    return if model.is_a?(Stance) && !model.shared_update_visible?

    MessageChannelService.publish_topic_models([ model ], topic: model.topic, group_id: model.group_id)
  end
end
