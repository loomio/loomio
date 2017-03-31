class Caches::DiscussionReader < Caches::Base
  private

  def default_values_for(discussion)
    resource_class.for(user: user, discussion: discussion).tap(&:save) if user.is_logged_in?
  end

  def single_entry
    true
  end

  def relation
    :discussion
  end
end
