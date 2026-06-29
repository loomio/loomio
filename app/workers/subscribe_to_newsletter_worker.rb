class SubscribeToNewsletterWorker < ApplicationJob
  def perform(name, email)
    NewsletterService.subscribe(name, email)
  end
end
