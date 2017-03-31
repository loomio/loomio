module UsesPolls
  private

  def default_scope
    super.merge poll_cache: Caches::Poll.new(user: current_user, parents: resources_to_serialize.map(&:discussion_id))
  end
end
