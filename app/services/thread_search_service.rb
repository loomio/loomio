class ThreadSearchService
  class << self
    def index!(discussion_ids)
      discussion_ids = Array(discussion_ids)
      SearchVector.where(discussion_id: discussion_ids).delete_all
      discussion_ids.each do |id|
        SearchVector.execute_search_query ThreadSearchQuery.index_thread_sql, id: id
        yield if block_given?
      end
    end

    handle_asynchronously :index!
  end

  def self.index_everything!
    index_thread_without_delay! Discussion.all.pluck(:id)
  end
end
