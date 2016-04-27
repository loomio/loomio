module PrettyUrlHelper
  include Routing

  def discussion_url(discussion, options = {})
    super(discussion, options.merge(slug: discussion.title.parameterize))
  end

  def group_url(group, options = {})
    super group, options.merge(slug: group.name.parameterize)
  end
end
