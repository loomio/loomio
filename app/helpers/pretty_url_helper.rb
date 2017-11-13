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
    when GroupIdentity,
         Membership,
         MembershipRequest             then polymorphic_url(model.group, opts)
    when GuestGroup                    then polymorphic_url(model.invitation_target, opts)
    when Reaction                      then polymorphic_url(model.reactable, opts)
    when PaperTrail::Version           then polymorphic_url(model.item, opts)
    when Stance                        then poll_url(model.poll, opts.merge(change_vote: true))
    when Comment                       then comment_url(model.discussion, model, opts)
    when FormalGroup                   then group_url(model, opts)
    when NilClass, LoggedOutUser       then nil
    else super
    end
  end

  def polymorphic_title(model)
    case model
    when PaperTrail::Version   then polymorphic_title(model.item)
    when Comment, Discussion   then model.discussion.title
    when Poll, Outcome, Stance then model.poll.title
    # TODO: deal with polymorphic reactions here
    when Reaction              then model.reactable.discussion.title
    when Group, Membership
      if model.group.is_a?(FormalGroup)
        eventable.group.full_name
      else
        eventable.group.invitation_target.title
      end
    end
  end

  def polymorphic_description(model)
    case model
    when PaperTrail::Version then polymorphic_description(model.item)
    when Group, Membership   then model.group.description
    when Discussion          then model.description
    when Poll                then model.details
    when Outcome             then model.statement
    when Stance              then model.reason
    when Comment             then model.body
    end
  end

end
