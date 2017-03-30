class Caches::DiscussionReader < Caches::Base
  private

  def default_cache_value
    
  end

  def only_owned_by_user
    true
  end

  def relation
    :discussion
  end
end
