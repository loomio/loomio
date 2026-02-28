class MigrateGuestsService
  def self.migrate!
    TopicReader
      .joins("INNER JOIN topics ON topics.id = topic_readers.topic_id")
      .joins("LEFT JOIN discussions ON topics.topicable_type = 'Discussion' AND topics.topicable_id = discussions.id")
      .where("topics.topicable_type = 'Discussion' AND topics.group_id IS NULL")
      .update_all(guest: true)
    Group.order('discussions_count desc').pluck(:id).each do |id|
      MigrateGuestOnDiscussionReadersAndStances.perform_async(id)
    end
  end
end
