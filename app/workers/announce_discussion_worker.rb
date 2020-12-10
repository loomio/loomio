class AnnounceDiscussionWorker
  include Sidekiq::Worker

  def perform(discussion_id, actor_id, params)
    DiscussionService.invite(
      discussion: Discussion.find(discussion_id),
      actor: User.find(actor_id),
      params: params.with_indifferent_access
    )
  end
end
