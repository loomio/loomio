
EventBus.listen('new_comment_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_comment(event.comment)) do |user|
    ThreadMailer.delay.new_comment(user, event)
  end
end

EventBus.listen('motion_closed_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.motion_closed(event.motion)) do |user|
    ThreadMailer.delay.motion_closed(user, event)
  end
end

EventBus.listen('motion_closing_soon_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.motion_closing_soon(event.motion)) do |user|
    ThreadMailer.delay.motion_closing_soon(user, event)
  end
end

EventBus.listen('motion_outcome_created_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.motion_outcome(event.motion)) do |user|
    ThreadMailer.delay.motion_outcome_created(user, event)
  end
end

EventBus.listen('new_discussion_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_discussion(event.discussion)) do |user|
    ThreadMailer.delay.new_discussion(user, event)
  end
end

EventBus.listen('new_motion_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_motion(event.motion)) do |user|
    ThreadMailer.delay.new_motion(user, event)
  end
end

EventBus.listen('new_vote_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_vote(event.vote)) do |user|
    ThreadMailer.delay.new_vote(user, event)
  end
end

EventBus.listen('comment_replied_to_event') { |user, event| ThreadMailer.delay.comment_replied_to(user, event) }
EventBus.listen('user_mentioned_event')     { |user, event| ThreadMailer.delay.user_mentioned(user, event) }
EventBus.listen('membership_request_approved_event') { |user, event| UserMailer.delay.group_membership_approved(user, event.group) }
