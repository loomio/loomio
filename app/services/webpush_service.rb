class WebpushService
  extend LocalesHelper

  def self.vapid_cert
    if WebpushCert.count == 0
      generated_cert = WebPush.generate_key
      WebpushCert.create(public_key: generated_cert.public_key, private_key: generated_cert.private_key)
    end

    stored_cert = WebpushCert.first

    return {
      private_key: stored_cert.private_key,
      public_key: stored_cert.public_key
    }

  end

  def self.push_event(recipient_id, event_id)
    @current_user = @recipient = User.active.find_by!(id: recipient_id)
    @subscriptions = WebpushSubscription.where(user_id: recipient_id)

    return if @subscriptions.count == 0

    @event = Event.find_by!(id: event_id)
    @notification = Notification.find_by(user_id: recipient_id, event_id: event_id)

    return if @event.eventable.nil?
    return if @event.eventable.respond_to?(:discarded?) && @event.eventable.discarded?

    if %w[Poll Stance Outcome].include? @event.eventable_type
      @poll = @event.eventable.poll
    end

    subject_params = {
      title: @event.eventable.title,
      group_name: @event.eventable.title, # cope for old translations
      poll_type: @poll && I18n.t("poll_types.#{@poll.poll_type}"),
      actor: @event.user.name,
      site_name: AppConfig.theme[:site_name]
    }

    # this should be notification.i18n_key
    @event_key = if (@event.kind == 'user_mentioned' &&
       @event.eventable.respond_to?(:parent) &&
       @event.eventable.parent.present? &&
       @event.eventable.parent.author == @recipient)
      "comment_replied_to"
    elsif @event.kind == 'poll_created'
      'poll_announced'
    else
      @event.kind
    end
    
    I18n.with_locale(WebpushService.first_supported_locale(@recipient.locale)) do
      message = {
        title: I18n.t("notifications.with_title.#{@event_key}", **subject_params).to_s,
        body: Nokogiri::HTML(@event.eventable.body).text.squeeze(" \n"),
        openTo: @notification.url,
        openToVerb: I18n.t("common.view"),
        timestamp: Time.now.to_i,
        iconUrl: AppConfig.theme[:icon_src],
      }

      begin
        begin
        @subscriptions.each do |s|
          response = WebPush.payload_send(
            message: message.to_json,
            endpoint: s.endpoint,
            p256dh: s.p256dh,
            auth: s.auth,
            vapid: WebpushService.vapid_cert,
            ssl_timeout: 5,
            open_timeout: 5,
            read_timeout: 5
          )
          rescue WebPush::ExpiredSubscription
            WebpushSubscription.delete_by(endpoint: s.endpoint, p256dh: s.p256dh)
          end
        end
      rescue StandardError => e
        raise "Webpush error when pushing to '#{@current_user.name}'. Error: #{e}"
      end
    end
  end

  def self.group_name_prefix(event)
      model = event.eventable
      if %w[membership_requested membership_created].include? event.kind
        ''
      else
        model.group.present? ? "[#{model.group.handle || model.group.full_name}] " : ''
      end
  end

end
