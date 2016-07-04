module UsesDiscussionReaders

  private

  def default_scope
    super.merge reader_cache: DiscussionReaderCache.new(user: current_user, discussions: collection)
  end
end
