class DiscussionReaderCache
  attr_accessor :user, :cache

  def initialize(user: nil, discussions: [])
    @user, @cache = user, {}
    return unless user && user.is_logged_in? && discussions

    readers = DiscussionReader.where(user_id: user.id, discussion_id: discussions.map(&:id))
    readers.each { |reader| cache[reader.discussion_id] = reader }
  end

  def get_for(discussion)
    cache.fetch(discussion.id) { DiscussionReader.for(discussion: discussion, user: user) }
  end

  def clear
    cache.clear
  end
end
