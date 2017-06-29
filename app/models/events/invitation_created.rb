class Events::InvitationCreated < Event
  def self.publish!(invitation, actor)
    create(kind: "invitation_created",
           user: actor,
           eventable: invitation,
           announcement: true,
           created_at: invitation.created_at).tap { |e| EventBus.broadcast('invitation_created_event', e) }
  end

  def poll
    eventable.group.invitation_target
  end

  def mailer
    case eventable.intent
    when 'join_group' then GroupMailer
    when 'join_poll' then PollMailer
    # when 'join_discussion' then DiscussionMailer
    end
  end

  def trigger!
    super
    mailer.delay(priority: 1).invitation_created(eventable, self)
    eventable.increment!(:send_count)
  end
end
