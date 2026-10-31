class BackfillPollSequenceWorker < ApplicationJob
  queue_as :low
  retry_on ActiveRecord::QueryCanceled, ActiveRecord::LockWaitTimeout, ActiveRecord::Deadlocked,
    wait: 5.seconds, attempts: 20

  # Convert newest records first and persist the descending cursor in each
  # continuation. NULL rows are the remaining work, so retries are idempotent
  # and edits made through the new setting are never overwritten.
  def perform(model_name: 'Topic', before_id: nil, batch_size: 500)
    model = {'Topic' => Topic, 'DiscussionTemplate' => DiscussionTemplate}.fetch(model_name)
    ids = model.transaction do
      model.connection.execute("SET LOCAL lock_timeout = '500ms'")
      model.connection.execute("SET LOCAL statement_timeout = '1s'")
      scope = model.where(polls_one_at_a_time: nil)
      scope = scope.where('id < ?', before_id) if before_id
      batch_ids = scope.order(id: :desc).limit(batch_size).ids
      model.where(id: batch_ids, polls_one_at_a_time: nil)
        .update_all('polls_one_at_a_time = NOT allow_concurrent_polls') if batch_ids.any?
      batch_ids
    end

    if ids.any?
      self.class.set(wait: 1.second).perform_later(model_name: model_name, before_id: ids.last, batch_size: batch_size)
    elsif model_name == 'Topic'
      self.class.set(wait: 1.second).perform_later(model_name: 'DiscussionTemplate', batch_size: batch_size)
    end
    ids
  end
end
