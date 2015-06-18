module DiscussionIndexCacheHelper

  def build_discussion_index_caches
    load_discussions_from_inbox if @inbox.present?

    discussion_reader_cache
    motion_reader_cache
    last_vote_cache
  end

  def clear_discussion_index_caches
    last_vote_cache.clear
    motion_reader_cache.clear
    discussion_reader_cache.clear
  end

  private

  def load_discussions_from_inbox
    @inbox.items_by_group do |group, items|
      @discussions = items.map { |item| item if item.is_a?(Discussion) }.compact
      @motions     = items.map { |item| item if item.is_a?(Motion) }.compact
    end
  end

  def discussion_reader_cache
    @discussion_reader_cache ||= DiscussionReaderCache.new user: current_user, discussions: @discussions
  end

  def motion_reader_cache
    @motion_reader_cache ||= MotionReaderCache.new current_user, Array(motion_readers)
  end

  def last_vote_cache
    @last_vote_cache ||= VoteCache.new current_user, Array(last_votes)
  end

  def motion_readers
    MotionReader.where(cache_motion_params).includes(:motion) if current_user
  end

  def last_votes
    Vote.most_recent.where(cache_motion_params) if current_user
  end

  def cache_motion_params
    { user_id: current_user.id, motion_id: current_motion_ids }
  end

  def current_motion_ids
    return unless @motions || @discussions
    @current_motion_ids ||= (@motions || @discussions.map(&:current_motion).compact).map(&:id)
  end

end
