class InviteDiscussionRecipientsWorker
  include Sidekiq::Worker

  def perform(discussion_id, actor_id, params)
    DiscussionService.announce(
      discussion: Discussion.find(discussion_id),
      actor: User.find(actor_id),
      params: params
    )
  end
end
