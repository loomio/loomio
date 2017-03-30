module UsesDiscussionReaders

  private

  def default_scope
    super.merge reader_cache: Caches::DiscussionReader.new(user: current_user, parents: collection)
  end
end
