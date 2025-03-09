module Events::Notify::WebPush
  def trigger!
    super
    push_event!
  end

  def push_event!
    email_recipients.active.uniq.pluck(:id).each do |recipient_id|
      WebpushService.push_event(recipient_id, self.id)
    end
  end
end
