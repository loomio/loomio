module PrettyUrlHelper
  include Routing

  def discussion_url(discussion, options = {})
    super(discussion, options.merge(slug: discussion.title.parameterize))
  end

  def group_url(group, options = {})
    if group.handle and !options[:use_key]
      group_handle_url(group.handle)
    else
      super group, options.merge(slug: group.name.parameterize)
    end
  end

  def polymorphic_url(model, opts = {})
    case model
    when NilClass, LoggedOutUser       then nil
    when FormalGroup, GroupIdentity    then group_url(model.group, opts)
    when PaperTrail::Version           then polymorphic_url(model.item, opts)
    when Membership, MembershipRequest then group_url(model.group, opts.merge(use_key: true))
    when Outcome                       then poll_url(model.poll, opts)
    when Stance                        then poll_url(model.poll, opts.merge(change_vote: true))
    when Comment                       then comment_url(model.discussion, model, opts)
    when Reaction                      then polymorphic_url(model.reactable, opts)
    when Announcement                  then polymorphic_url(model.eventable, opts)
    else super
    end
  end

  def polymorphic_title(model)
    case model
    when PaperTrail::Version   then model.item.title
    when Comment, Discussion   then model.discussion.title
    when Poll, Outcome, Stance then model.poll.title
    when Announcement          then polymorphic_title(model.eventable)
    # TODO: deal with polymorphic reactions here
    when Reaction              then model.reactable.discussion.title
    when Group, Membership
      if model.group.is_a?(FormalGroup)
        model.group.full_name
      else
        model.group.invitation_target.title
      end
    end
  end

end
