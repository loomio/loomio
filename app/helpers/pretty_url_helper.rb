module PrettyUrlHelper
  include Routing

  def join_url(model, opts = {})
    super opts.merge(model: model.class.to_s.underscore, token: model.group.token)
  end

  def discussion_url(discussion, options = {})
    super(discussion, options.merge(slug: discussion.title.parameterize))
  end

  def group_url(group, options = {})
    if group.handle and !options.delete(:use_key)
      group_handle_url(group.handle, options)
    else
      super group, options.merge(slug: group.name.parameterize)
    end
  end

  def discussion_poll_url(poll, options = {})
    if poll.discussion.present?
      discussion_url(poll.discussion, options.merge(sequence_id: poll.created_event.sequence_id))
    else
      poll_url(poll, options)
    end
  end

  def polymorphic_url(model, opts = {})
    case model
    when NilClass, LoggedOutUser       then nil
    when Group, GroupIdentity          then group_url(model.group, opts)
    when PaperTrail::Version           then polymorphic_url(model.item, opts)
    when MembershipRequest             then group_url(model.group, opts.merge(use_key: true))
    when Poll                          then discussion_poll_url(model.poll, opts)
    when Outcome                       then discussion_poll_url(model.poll, opts)
    when Stance                        then discussion_poll_url(model.poll, opts.merge(change_vote: model.poll.id))
    when Comment                       then comment_url(model.discussion, model, opts)
    when Membership                    then membership_url(model, opts)
    when Reaction                      then polymorphic_url(model.reactable, opts)
    else super
    end
  end

  def polymorphic_path(model, opts = {})
    # angular router throws error if you give it a whole url
    polymorphic_url(model, opts).sub(root_url, '')
  end

  def polymorphic_title(model)
    case model
    when PaperTrail::Version   then model.item.title
    when Comment, Discussion   then model.discussion.title
    when Poll, Outcome, Stance then model.poll.title
    when Reaction              then model.reactable.title
    when Group                 then model.full_name
    when Membership            then polymorphic_title(model.group)
    end
  end
end
