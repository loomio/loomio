module UsesPolls
  private

  def default_scope
    super.merge poll_cache: Caches::Poll.new(parents: resources_to_serialize.map(&:discussion))
  end
end
