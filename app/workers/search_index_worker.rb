class SearchIndexWorker
  include Sidekiq::Worker

  def perform(discussion_ids)
    ids = Array(discussion_ids).map(&:to_i).uniq
    SearchVector.where(discussion_id: ids).find_each(&:update_search_vector)
    existing = SearchVector.where(discussion_id: ids).pluck(:discussion_id).uniq
    (ids - existing).each { |discussion_id| SearchVector.new(discussion_id: discussion_id).update_search_vector }
  end
end
