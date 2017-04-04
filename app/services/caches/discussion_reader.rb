class Caches::DiscussionReader < Caches::Base
  private

  def require_user?
    true
  end

  def collection_from(parents)
    super.where(user: user)
  end

  def default_values_for(discussion)
    resource_class.for(user: user, discussion: discussion).tap(&:save) if user.is_logged_in?
  end

  def relation
    :discussion
  end
end
