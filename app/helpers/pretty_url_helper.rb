module PrettyUrlHelper
  include Routing

  def discussion_url(discussion, options = {})
    super(discussion, options.merge(slug: discussion.title.parameterize))
  end

  def group_url(group, options = {})
    super group, options.merge(slug: group.name.parameterize)
  end

  def polymorphic_url(model, opts = {})
    return unless model
    case model
    when Comment then comment_url(model.discussion, model, opts)
    else super
    end
  end

end
