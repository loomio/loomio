class ThreadMailer < BaseMailer
  helper :email
  helper :application
  layout 'thread_mailer'
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF

  def new_discussion(recipient, event)
    @recipient = recipient
    @event = event
    @discussion = event.eventable
    @author = @discussion.author
    @link = polymorphic_url(@discussion, @utm_hash)
    send_thread_email
  end

  def new_comment(recipient, event)
    @recipient = recipient
    @event = event
    @comment = event.eventable
    @discussion = @comment.discussion
    @author = @comment.author
    @link = polymorphic_url(@comment, @utm_hash)
    send_thread_email
  end

  def user_mentioned(recipient, event)
    @recipient = recipient
    @event = event
    @eventable = event.eventable
    @text = case @eventable
    when Discussion, Motion then @eventable.description
    when Comment            then @eventable.body
    end
    @discussion = @eventable.is_a?(Discussion) ? @eventable : @eventable.discussion
    @author = @eventable.author
    @link = polymorphic_url(@eventable)
    send_thread_email(subject_key: 'email.mentioned.subject',
                      subject_params: { who: @author.name,
                                        which: @discussion.title } )
  end

  def comment_replied_to(recipient, event)
    @recipient = recipient
    @event = event
    @reply = event.eventable
    @discussion = @reply.discussion
    @author = @reply.author
    @link = polymorphic_url(@reply, @utm_hash)
    send_thread_email(subject_key: 'email.comment_replied_to.subject',
                      subject_params: { who: @author.name,
                                        which: @discussion.group.full_name })
  end

  def new_vote(recipient, event)
    @recipient = recipient
    @event = event
    @vote = event.eventable
    @discussion = @vote.motion.discussion
    @author = @vote.author
    @motion = @vote.motion
    @link = polymorphic_url(@motion, @utm_hash)
    send_thread_email
  end

  def new_motion(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.author
    @group = @discussion.group
    @link = polymorphic_url(@motion, @utm_hash)
    send_thread_email(subject_key: "email.new_motion_created.subject",
                      subject_params: {proposal_title: @motion.title})
  end

  def motion_closing_soon(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @author = @motion.author
    @discussion = @motion.discussion
    @group = @discussion.group
    @link = polymorphic_url(@motion, @utm_hash)
    return if @author == User.helper_bot
    send_thread_email(subject_key: "email.proposal_closing_soon.subject",
                      subject_params: {proposal_title: @motion.title})
  end

  def motion_outcome_created(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.outcome_author
    @group = @motion.group
    @link = polymorphic_url(@motion, @utm_hash)
    send_thread_email(subject_key: "email.proposal_outcome.subject",
                      subject_params: {motion: @motion.name})
  end

  def motion_closed(recipient, event)
    @recipient = recipient
    @event = event
    @motion = event.eventable
    @discussion = @motion.discussion
    @author = @motion.author
    @motion = @motion
    @group = @motion.group
    @link = polymorphic_url(@motion, @utm_hash)
    return if @author == User.helper_bot
    send_thread_email(subject_key: "email.proposal_closed.subject",
                      subject_params: {which: @motion.name})
  end

  private

  def send_thread_email(subject_key: nil, subject_params: nil)
    @following = DiscussionReader.for(discussion: @discussion, user: @recipient).volume_is_loud?
    @utm_hash = utm_hash

    headers[message_id_header] = message_id
    headers['Precedence'] = 'bulk'
    headers['X-Auto-Response-Suppress'] = 'OOF'
    headers['Auto-Submitted'] = 'auto-generated'

    if subject_key.nil? or @following
      subject_key = 'email.custom'
      subject_params = {text: "[#{@discussion.group.full_name}] #{@discussion.title}"}
    end

    send_single_mail  to: @recipient.email,
                      from: from_user_via_loomio(@author),
                      reply_to: reply_to_address_with_group_name(discussion: @discussion, user: @recipient),
                      subject_key: subject_key,
                      subject_params: subject_params,
                      locale: @recipient.locale
  end

  def message_id_header
    action_name == 'new_discussion' ? 'Message-ID' : 'In-Reply-To'
  end

  def message_id
    "<#{@discussion.id}@#{ENV['SMTP_DOMAIN']}>"
  end
end
