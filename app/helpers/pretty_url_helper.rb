module PrettyUrlHelper
  include Routing

  private

  def join_url(model, opts = {})
    super opts.merge(model: model.class.to_s.underscore, token: model.guest_group.token)
  end

  def discussion_url(discussion, options = {})
    super(discussion, options.merge(slug: discussion.title.parameterize))
  end

  def group_url(group, options = {})
    if group.is_parent? and group.handle and !options.delete(:use_key)
      group_handle_url(group.handle)
    else
      super group, options.merge(slug: group.name.parameterize)
    end
  end

  def polymorphic_url(model, opts = {})
    case model
    when NilClass, LoggedOutUser       then nil
    when GuestGroup                    then polymorphic_url(model.target_model, opts)
    when FormalGroup, GroupIdentity    then group_url(model.group, opts)
    when PaperTrail::Version           then polymorphic_url(model.item, opts)
    when MembershipRequest             then group_url(model.group, opts.merge(use_key: true))
    when Outcome                       then poll_url(model.poll, opts)
    when Stance                        then poll_url(model.poll, opts.merge(change_vote: true))
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
    when Reaction              then model.reactable.discussion.title # TODO: deal with polymorphic reactions here
    when Group                 then model.full_name
    when Membership            then polymorphic_title(model.target_model)
    end
  end
end
