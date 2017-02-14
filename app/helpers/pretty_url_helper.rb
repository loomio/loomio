module PrettyUrlHelper
  include Routing

  def discussion_url(discussion, options = {})
    super(discussion, options.merge(slug: discussion.title.parameterize))
  end

  def group_url(group, options = {})
    super group, options.merge(slug: group.name.parameterize)
  end

  def polymorphic_url(model, opts = {})
    case model
    when NilClass                      then nil
    when PaperTrail::Version           then polymorphic_url(model.item, opts)
    when Membership, MembershipRequest then group_url(model.group, opts)
    when Outcome                       then poll_url(model.poll, opts)
    when Comment                       then comment_url(model.discussion, model, opts)
    when CommentVote                   then comment_url(model.discussion, model.comment, opts)
    else super
    end
  end

end
