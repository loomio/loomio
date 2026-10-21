class InboundEmailService
  def self.refresh_forward_email_rules
    forward_email_rules = File.readlines(Rails.root.join("db/default_forward_email_rules.txt")).map(&:chomp).map do |handle|
      {handle: handle, email: "#{handle}@#{ENV['REPLY_HOSTNAME']}"}
    end

    ForwardEmailRule.transaction(requires_new: true) do
      ForwardEmailRule.delete_all
      ForwardEmailRule.insert_all!(forward_email_rules, record_timestamps: false)
    end
  end

  def self.banned_sender_hosts
    ENV.slice('REPLY_HOSTNAME', 'CANONICAL_HOST').values.compact.map(&:downcase)
  end

  # Process the first stored source for each Message-ID. Relay retries may have
  # different checksums; serialize them and commit domain changes with the
  # completion marker so failures can retry without duplicating a thread.
  def self.process(inbound_email)
    ActionMailbox::InboundEmail.transaction do
      connection = ActionMailbox::InboundEmail.connection
      key = connection.quote("inbound-email:#{inbound_email.message_id}")
      connection.execute("SELECT pg_advisory_xact_lock(hashtextextended(#{key}, 0))")
      source = ActionMailbox::InboundEmail.where(message_id: inbound_email.message_id)
        .order(Arel.sql('processing_completed_at IS NULL'), :id).first!
      return source.bounced? ? :bounced : :delivered if source.processing_completed_at

      message = InboundEmailMessage.new(source)
      result = if EmailFeedbackService.feedback_sender?(message)
        EmailFeedbackService.process(source)
        :delivered
      else
        route(message)
      end
      attributes = {processing_completed_at: Time.current}
      # The current mailbox owns its status transition and cleanup job. Only a
      # retry using another receipt must also finish the original source.
      attributes[:status] = result == :bounced ? :bounced : :delivered if source.id != inbound_email.id
      source.update!(attributes)
      result
    end
  end

  def self.retry_pending
    aliases = MemberEmailAlias.blocked
      .where('member_email_aliases.group_id = pending_emails.group_id')
      .where('member_email_aliases.email = pending_emails.sender_email')
    PendingEmail.blocked.where.not(aliases.arel.exists).find_each { |pending| approve(pending) }
  end

  def self.approve(pending)
    pending.with_lock do
      result = route_to_group(pending.message, pending.group)
      pending.destroy! unless result == :pending
    end
  end

  def self.route(email)
    return :bounced unless email.sender_email && email.is_addressed_to_loomio? && !email.is_auto_response?

    # Replies sent to the notifications "From" address → send a delivery-failure notice (throttled)
    if email.sent_to_notifications_address?
      if ThrottleService.can?(key: 'bounce', id: email.sender_email.downcase, max: 1, per: 'hour')
        Rails.logger.info("email bounced");
        ForwardMailer.bounce(to: email.sender_name_and_email).deliver_later
      else
        Rails.logger.info("bounce throttled for #{email.sender_email}");
      end
      return :bounced
    end

    # Block banned sender hostnames early
    if banned_sender_hosts.include? email.sender_hostname.downcase
      Rails.logger.info("banned sender_hostname: #{email.sender_hostname}")
      return :bounced
    end

    # Require a valid Loomio route address from here
    return :bounced unless email.route_address

    # Handle personal email-to-thread and email-to-group routes first
    case email.route_path
    when /d=.+&u=.+&k=.+/
      # personal email-to-thread, eg. d=100&k=asdfghjkl&u=999@mail.loomio.com
      Rails.logger.info("creating comment from email for #{email.sender_email}");
      create_comment_from_email(email)
      return :delivered
    when /[^\s]+\+u=.+&k=.+/
      # personal email-to-group, eg. enspiral+u=99&k=adsfghjl@mail.loomio.com
      if AppConfig.app_features[:thread_from_mail]
        group = group_from_route_path(parse_route_params(email.route_path).fetch('handle'))
        actor = actor_from_email(email)
        discussion = DiscussionService.create(params: discussion_params(email, group: group), actor: actor)
        raise ActiveRecord::RecordInvalid, discussion if discussion.invalid?

        return :delivered
      end
    end

    # Forwarding rule by handle
    if forward_email_rule = ForwardEmailRule.find_by(handle: email.route_path)
      Rails.logger.info("email forwarded");
      ForwardMailer.forward_message(
        from: "\"#{email.sender_name}\" <#{ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS}>",
        to: forward_email_rule.email,
        reply_to: email.from,
        subject: email.subject,
        body_text: email.body_text,
        body_html: email.body_html
      ).deliver_later
      return :delivered
    end

    if group = group_from_route_path(email.route_path)
      return route_to_group(email, group)
    end

    # Default: no suitable route
    Rails.logger.info("no suitable route for address: #{email.route_path}")
    return :bounced
  rescue CanCan::AccessDenied, ActiveRecord::RecordNotFound
    :bounced
  end

  def self.extract_reply_body(text, author_name = nil)
    return "" if text.strip.blank?
    text = text.gsub("\r\n", "\n")

    # some emails match multiple split points, we run this until there are none
    while regex = reply_split_points(author_name).find { |regex| regex.match? text } do
      text = text.split(regex).first.strip
    end

    text.strip
  end

  private

  # The queued group is the destination of a held message, even if its old
  # handle is later reassigned. Approval must never reroute to another group.
  def self.route_to_group(email, group)
    return :bounced unless Group.enabled.exists?(group.id)

    if address_is_blocked(email, group)
      hold(email, group, status: :blocked)
    elsif email.sender_authentication_failed?
      hold(email, group, status: :pending)
    elsif actor = actor_from_email_and_group(email, group)
      discussion = DiscussionService.create(params: discussion_params(email, group: group), actor: actor)
      raise ActiveRecord::RecordInvalid, discussion if discussion.invalid?

      :delivered
    else
      hold(email, group, status: :pending)
    end
  rescue CanCan::AccessDenied
    :bounced
  end

  def self.hold(email, group, status:)
    pending = PendingEmail.find_or_initialize_by(inbound_email: email.inbound_email)
    return :pending if pending.persisted? && pending.status == status.to_s

    pending.assign_attributes(group: group, status: status)
    pending.save!
    if pending.pending?
      NotificationService.create!(kind: 'unknown_sender', subject: pending, actor: nil)
    else
      pending.notifications.destroy_all
    end
    :pending
  end

  def self.reply_split_points(author_name = nil)
    [
      /^[[:space:]]*[-]+[[:space:]]*Original Message[[:space:]]*[-]+[[:space:]]*$/i,
      /^[[:space:]]*--[[:space:]]*$/,
      /^[[:space:]]*__[[:space:]]*$/,
      /^[[:space:]]*\>?[[:space:]]*On.*\n?.*wrote:\n?$/,
      /^[[:space:]]*\>?[[:space:]]*On.*\n?.*said:\n?$/,
      /^On.*<\r?\n?.*>.*\r?\n?wrote:\r?\n?$/,
      /On.*wrote:/,
      (author_name ? /^[[:space:]]*#{author_name}[[:space:]]*$/ : nil), # signature that starts with author name
      /#{NotificationMailer::REPLY_DELIMITER}/,
      /\*?From:.*$/i,
      /^[[:space:]]*\d{4}[-\/]\d{1,2}[-\/]\d{1,2}[[:space:]].*[[:space:]]<.*>?$/i,
      /(_)*\n[[:space:]]*De :.*\n[[:space:]]*Envoyé :.*\n[[:space:]]*À :.*\n[[:space:]]*Objet :.*\n$/i, # French Outlook
      /^[[:space:]]*\>?[[:space:]]*Le.*<\n?.*>.*\n?a[[:space:]]?\n?écrit :$/, # French
      /^[[:space:]]*\>?[[:space:]]*El.*<\n?.*>.*\n?escribió:$/,
      /^[[:space:]]*\>?[[:space:]]*El.*<\n?.*>.*\n?escribiÃ:$/,
      /^[[:space:]]*\>?[[:space:]]*El.*<\n?.*>.*\n?escribiÃ³:$/
    ].compact
  end

  def self.parse_route_params(route_path)
    params = {}.with_indifferent_access

    if route_path.include?('+')
      params['handle'] = route_path.split('+').first
    end

    route_path.split('+').last.split('&').each do |segment|
      key_and_value = segment.split('=')
      params[key_and_value[0]] = key_and_value[1]
    end

    params
  end

  def self.actor_from_email(email)
    params = parse_route_params(email.route_path)
    User.find_by!(id: params['u'], email_api_key: params['k'])
  end

  def self.address_is_blocked(email, group)
    MemberEmailAlias.blocked.find_by(email: email.sender_email, group_id: group.id)
  end

  def self.actor_from_email_and_group(email, group)
    if actor = User.find_by(email: email.sender_email)
      return actor if group.members.exists?(actor.id)
    end

    if email_alias = MemberEmailAlias.allowed.find_by(email: email.sender_email, group_id: group.id)
      return email_alias.user if group.members.exists?(email_alias.user.id)
    end

    nil
  end

  def self.group_from_route_path(route_path)
    Group.find_by(handle: route_path) ||
      GroupHandleRedirect.find_by(handle: route_path)&.group
  end

  def self.discussion_params(email, group:)
    group || raise(ActiveRecord::RecordNotFound)
    {
      group_id: group.id,
      private: group.discussion_private_default,
      title: email.subject,
      body: email.full_body,
      body_format: email.body_format,
      files: email.files,
      max_depth: 3
    }.compact
  end

  def self.comment_params(email)
    params = parse_route_params(email.route_path)

    if params['c'].present?
      parent_id     = params['c']
      parent_type   = "Comment"
    end

    if params['pt'].present?
      parent_type = {
        'p' => 'Poll',
        'c' => 'Comment',
        's' => 'Stance',
        'o' => 'Outcome'
      }[params['pt']]
      parent_id = params['pi']
    end

    unless parent_id
      parent_id = params['d'].to_i
      parent_type = 'Discussion'
    end

    {
      parent_id: parent_id,
      parent_type: parent_type,
      body: email.reply_body,
      body_format: 'md',
      files: email.files
    }.compact
  end

  def self.create_comment_from_email(email)
    actor = actor_from_email(email)
    comment = CommentService.create(comment: Comment.new(comment_params(email)), actor: actor)
    return comment if comment.errors.empty?

    Rails.logger.info("email comment invalid: #{comment.errors.full_messages.join(', ')}")
    send_comment_rejected_email(email, comment)
    nil
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.info("email comment invalid: #{e.record.errors.full_messages.join(', ')}")
    send_comment_rejected_email(email, e.record)
    nil
  end

  def self.send_comment_rejected_email(email, comment)
    return unless ThrottleService.can?(key: 'comment_rejected', id: email.sender_email.downcase, max: 1, per: 'hour')

    ForwardMailer.comment_rejected(to: email.sender_name_and_email, topic: comment.topic).deliver_later
  end
end
