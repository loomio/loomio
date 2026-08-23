class DeliveryMailer < ApplicationMailer
  REPLY_DELIMITER = "\uFEFF\uFEFF"*4 # surprise! this is actually U+FEFF

  def topic_item(recipient_id, topic_item_id)
    recipient = User.active.find_by!(id: recipient_id)
    topic_item = TopicItem.find_by!(id: topic_item_id)
    deliver_notification(topic_item: topic_item, recipient: recipient, notification: nil)
  end

  def notification(notification_delivery_id)
    delivery = NotificationDelivery.find_by!(
      id: notification_delivery_id,
      channel: "email",
      recipient_type: "User"
    )
    recipient = User.active.find_by!(id: delivery.recipient_id)
    notification = delivery.notification
    topic_item = NotificationRenderingContext.new(notification)

    deliver_notification(topic_item: topic_item, recipient: recipient, notification: notification)
  end

  def self.event_key_for(topic_item, recipient)
    if topic_item.kind == 'user_mentioned' &&
       topic_item.itemable.respond_to?(:parent) &&
       topic_item.itemable.parent.present? &&
       topic_item.itemable.parent.author == recipient
      "comment_replied_to"
    else
      topic_item.kind
    end
  end

  def self.build_component(topic_item:, recipient:, event_key: nil, poll: nil, discussion: nil, notification: nil, membership: nil, utm_hash: {})
    event_key ||= event_key_for(topic_item, recipient)
    poll ||= topic_item.itemable.poll if %w[Poll Stance Outcome].include?(topic_item.itemable_type)
    discussion ||= topic_item.topic&.topicable_type == 'Discussion' ? topic_item.topic.topicable : nil

    if topic_item.kind == 'discussion_announced'
      return Views::DeliveryMailer::Topic.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key,
        notification: notification, topic: topic_item.itemable.topic, membership: membership
      )
    end

    case topic_item.itemable_type
    when 'Topic'
      Views::DeliveryMailer::Topic.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key,
        notification: notification, topic: topic_item.itemable, membership: membership
      )
    when 'Poll', 'Outcome'
      Views::DeliveryMailer::Poll.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key,
        poll: poll, notification: notification, discussion: discussion, membership: membership
      )
    when 'Discussion'
      Views::DeliveryMailer::Topic.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key,
        notification: notification, topic: topic_item.itemable.topic, membership: membership
      )
    when 'Comment'
      Views::DeliveryMailer::Comment.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key,
        notification: notification, discussion: discussion, poll: poll, membership: membership
      )
    when 'Stance'
      Views::DeliveryMailer::Stance.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key,
        notification: notification, discussion: discussion, poll: poll, membership: membership
      )
    when 'Membership'
      Views::DeliveryMailer::Membership.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key
      )
    when 'Group'
      Views::DeliveryMailer::Group.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key
      )
    when 'MembershipRequest'
      Views::DeliveryMailer::MembershipRequest.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key, utm_hash: utm_hash
      )
    when 'ReceivedEmail'
      Views::ReceivedEmailMailer.new(
        topic_item: topic_item, recipient: recipient, event_key: event_key
      )
    end
  end

  private

  def deliver_notification(topic_item:, recipient:, notification:)
    return if topic_item.itemable.nil?
    return if topic_item.itemable.respond_to?(:discarded?) && topic_item.itemable.discarded?

    poll = if %w[Poll Stance Outcome].include? topic_item.itemable_type
      topic_item.itemable.poll
    end

    discussion = topic_item.itemable.respond_to?(:topic) ? topic_item.itemable.topic.discussion : nil

    membership = if topic_item.itemable.respond_to?(:group_id) && topic_item.itemable.group_id
      m = Membership.active.find_by(
        group_id: topic_item.itemable.group_id,
        user_id: recipient.id
      )

      # this might be necessary to comply with anti-spam rules
      # if someone does not respond to the invitation, don't send them more emails
      return if m &&
                !recipient.email_verified &&
                ![ "membership_created", "membership_resent" ].include?(topic_item.kind)
      m
    end

    utm_hash = { utm_medium: 'email', utm_campaign: topic_item.kind }

    headers = {
      "Precedence": :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted": :"auto-generated"
    }

    if topic_item.itemable.respond_to?(:calendar_invite) && topic_item.itemable.calendar_invite
      attachments['meeting.ics'] = {
        content_type: 'text/calendar',
        content_transfer_encoding: 'base64',
        content: Base64.encode64(topic_item.itemable.calendar_invite)
      }
    end

    # this should be notification.i18n_key
    event_key = self.class.event_key_for(topic_item, recipient)

    component = self.class.build_component(
      topic_item: topic_item,
      recipient: recipient,
      event_key: event_key,
      poll: poll,
      discussion: discussion,
      notification: notification,
      membership: membership,
      utm_hash: utm_hash
    )

    return if spam?(recipient.email) || rejected_address?(recipient.email)

    I18n.with_locale(first_supported_locale(recipient.locale)) do
      mail(
        to: recipient.email,
        from: from_user_via_loomio(topic_item.user),
        reply_to: reply_to_address_with_group_name(model: topic_item.itemable, user: recipient),
        subject: subject_for(topic_item: topic_item, recipient: recipient, event_key: event_key, poll: poll)
      ) do |format|
        format.html { render component }
      end
    end
  end

  def subject_for(topic_item:, recipient:, event_key:, poll: nil)
    title_model = topic_item.itemable.is_a?(Topic) ? topic_item.itemable.topicable : topic_item.itemable.title_model
    subject_params = {
      title: TranslationService.plain_text(title_model, :title, recipient),
      poll_type: poll && I18n.t("decision_tools_card.#{poll.poll_type}_title", locale: recipient.locale),
      actor: topic_item.user.name,
      site_name: AppConfig.theme[:site_name]
    }

    if topic_subject_event?(topic_item)
      group_name_prefix(topic_item) + subject_params[:title]
    else
      group_name_prefix(topic_item) + I18n.t("notifications.email_subject.#{event_key}", **subject_params)
    end
  end

  def topic_subject_event?(topic_item)
    %w[
      new_comment
      new_discussion
      discussion_edited
      discussion_announced
    ].include?(topic_item.kind)
  end

  def group_name_prefix(topic_item)
    model = topic_item.itemable
    if %w[membership_requested membership_created].include? topic_item.kind
      ''
    else
      model.group.present? ? "[#{model.group.handle || model.group.full_name}] " : ''
    end
  end

  def reply_to_address_with_group_name(model:, user:)
    return nil unless user.is_logged_in?
    return nil unless model.respond_to?(:topic) && model.topic.present?

    if model.topic.group.present?
      "\"#{I18n.transliterate(model.topic.group.full_name).truncate(50).delete('"')}\" <#{reply_to_address(model: model, user: user)}>"
    else
      "\"#{user.name}\" <#{reply_to_address(model: model, user: user)}>"
    end
  end
end
