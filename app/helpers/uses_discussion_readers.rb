module UsesDiscussionReaders
  private

  def default_scope
    super.merge(reader_cache: Caches::DiscussionReader.new(
      user: current_user,
      parents: resources_to_serialize.map(&:discussion)
    ))
  end
end
