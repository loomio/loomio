module UsesPolls
  private

  def default_scope
    super.merge(poll_cache: poll_cache)
    # super.merge(poll_cache: poll_cache, my_stances_cache: stance_cache)
  end

  def poll_cache
    @poll_cache ||= Caches::Poll.new(parents: discussions_to_serialize)
  end

  # def stance_cache
  #   @stance_cache ||= Caches::Stance.new(parents: Poll.where(discussion: discussions_to_serialize), user: current_user)
  # end

  def discussions_to_serialize
    @discussions_to_serialize ||= resources_to_serialize.map(&:discussion)
  end
end
