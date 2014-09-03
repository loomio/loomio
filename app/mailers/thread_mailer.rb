class ThreadMailer < BaseMailer
  helper :email
  helper :motions
  helper :application

  def new_discussion(recipient, event)
    @recipient = recipient
    @event = event
    @discussion = event.discussion
    @author = event.discussion.author
    headers['Message-ID'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email
  end

  def new_comment(recipient, event)
    @recipient = recipient
    @event = event
    @comment = event.eventable
    @discussion = @comment.discussion
    @author = @comment.author
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email
  end

  def user_mentioned(recipient, event)
    @recipient = recipient
    @event = event
    @comment = event.eventable
    @discussion = @comment.discussion
    @author = @comment.author
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email(alternative_subject: t('email.mentioned.subject',
                                             who: @author.name,
                                             which: @discussion.group.full_name))
  end

  def new_vote(recipient, event)
    @recipient = recipient
    @event = event
    @vote = event.eventable
    @discussion = @vote.motion.discussion
    @author = @vote.author
    @motion = @vote.motion
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email
  end

  def new_motion(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.author
    @group = @discussion.group
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email(alternative_subject: t(:"email.new_motion_created.subject",
                                             proposal_title: @motion.title))
  end

  def motion_closing_soon(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @author = @motion.author
    @discussion = @motion.discussion
    @group = @discussion.group
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email(alternative_subject:
                      t(:"email.proposal_closing_soon.subject", proposal_title: @motion.title))
  end

  def motion_outcome_created(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.outcome_author
    @group = @motion.group
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email(alternative_subject:
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
    headers['Message-ID'] = "#{@discussion.id}/#{@event.id}@#{ENV['SMTP_DOMAIN']}"
    headers['References'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    headers['In-Reply-To'] = "#{@discussion.id}@#{ENV['SMTP_DOMAIN']}"
    send_thread_email(alternative_subject:
                      t("email.proposal_closed.subject", which: @motion.name))
  end

  private

  def send_thread_email(alternative_subject: nil)
    @following = DiscussionReader.for(discussion: @discussion, user: @recipient).following?
    @utm_hash = utm_hash

    locale = locale_fallback(@recipient.locale, @author.locale)
    I18n.with_locale(locale) do
      mail  to: @recipient.email,
            from: from_user_via_loomio(@author),
            reply_to: reply_to_address_with_group_name(discussion: @discussion, user: @recipient),
            subject: thread_subject(alternative_subject)
    end
  end

  def thread_subject(alternative_subject)
    if @recipient.email_followed_threads? and @following
      "[#{@discussion.group.full_name}] #{@discussion.title}"
    else
      alternative_subject
    end
  end
end

