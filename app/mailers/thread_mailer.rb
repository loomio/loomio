class ThreadMailer < BaseMailer
  helper :email
  helper :motions
  helper :application

  def new_discussion(recipient, event)
    @recipient = recipient
    @event = event
    @discussion = event.discussion
    @author = event.discussion.author
    send_thread_email(non_following_subject: @discussion.title)
  end

  def new_comment(recipient, event)
    @recipient = recipient
    @event = event
    @comment = event.eventable
    @discussion = @comment.discussion
    @author = @comment.author
    send_thread_email
  end

  def new_vote(recipient, event)
    @recipient = recipient
    @event = event
    @vote = event.eventable
    @discussion = @vote.motion.discussion
    @author = @vote.author
    @motion = @vote.motion
    send_thread_email
  end

  def new_motion(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.author
    @group = @discussion.group
    send_thread_email(non_following_subject:
                      t(:"email.new_motion_created.subject", proposal_title: @motion.title))
  end

  def motion_closing_soon(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @author = @motion.author
    @discussion = @motion.discussion
    @group = @discussion.group
    send_thread_email(non_following_subject:
                      t(:"email.proposal_closing_soon.subject", proposal_title: @motion.title))
  end

  def motion_outcome_created(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.outcome_author
    @group = @motion.group
    send_thread_email(non_following_subject:
                      "#{t("email.proposal_outcome.subject")}: #{@motion.name}")
  end

  def motion_closed(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.author
    @motion = @motion
    @group = @motion.group
    send_thread_email(non_following_subject:
                      t("email.proposal_closed.subject", which: @motion.name))
  end

  private

  def send_thread_email(non_following_subject: nil)
    @following = DiscussionReader.for(discussion: @discussion, user: @recipient).following?
    @utm_hash = utm_hash

    locale = locale_fallback(@recipient.locale, @author.locale)
    I18n.with_locale(locale) do
      mail  to: @recipient.email,
            from: from_user_via_loomio(@author),
            reply_to: reply_to_address(discussion: @discussion, user: @recipient),
            subject: thread_subject(non_following_subject)
    end
  end

  def thread_subject(non_following_subject)
    if @following
      @discussion.title
    else
      non_following_subject
    end
  end
end
