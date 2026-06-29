class PublishReviewDueWorker < ApplicationJob
  def perform
    OutcomeService.publish_review_due
  end
end
