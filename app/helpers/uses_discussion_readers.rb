module UsesDiscussionReaders

  private

  def respond_with_collection(**args)
    args[:scope] ||= {}
    args[:scope][:reader_cache] = DiscussionReaderCache.new(user: current_user, discussions: collection)
    super args
  end
end
