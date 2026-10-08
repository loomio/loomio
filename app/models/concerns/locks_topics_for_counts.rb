module LocksTopicsForCounts
  # Serialize child writes with topic moves before updating group counts. The
  # mutual topic/topicable autosave may initially have no topic ID; callers use
  # the loaded group until the second save links the persisted topic.
  def lock_topics_for_counts
    ids = [topic_id, topic_id_in_database].compact.uniq
    @count_group_ids = Topic.where(id: ids).order(:id).lock('FOR NO KEY UPDATE').pluck(:id, :group_id).to_h
  end
  private :lock_topics_for_counts
end
