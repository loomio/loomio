class Caches::DiscussionReader < Caches::Base
  private

  def default_values_for(discussion)
    DiscussionReader.for(user: @user, discussion: discussion)
  end

  def only_owned_by_user
    true
  end

  def relation
    :discussion
  end
end
