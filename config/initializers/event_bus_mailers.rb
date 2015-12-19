
EventBus.listen('new_comment_event') do |event|
  BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_comment(event.comment)) do |user|
    ThreadMailer.delay.new_comment(user, event)
  end
end

EventBus.listen('comment_replied_to_event') { |user, event| ThreadMailer.delay.comment_replied_to(user, event) }
EventBus.listen('user_mentioned_event')     { |user, event| ThreadMailer.delay.user_mentioned(user, event) }
