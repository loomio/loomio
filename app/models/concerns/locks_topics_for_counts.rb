module LocksTopicsForCounts
  # Serialize child writes with topic moves before updating group counts. The
  # mutual topic/topicable autosave may initially have no topic ID; callers use
  # the loaded group until the second save links the persisted topic.
  def with_topics_write_lock_for_counts
    ids = [topic_id, topic_id_in_database].compact.uniq
    Topic.where(id: ids).order(:id).with_write_lock(:id, :group_id) do |rows|
      @count_group_ids = rows.to_h
      yield
    end
  end
  private :with_topics_write_lock_for_counts
end
