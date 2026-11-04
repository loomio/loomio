# Mail normally discards the SMTP response. Keep it on this message's transport
# so SES's assigned message ID can be matched to later feedback, without changing
# the application's SMTP credentials or the transport used by other mailers.
class NotificationSmtpDelivery < Mail::SMTP
  attr_reader :response

  def initialize(settings)
    super(settings.merge(return_response: true))
  end

  def deliver!(mail)
    @response = super
  end

  def provider_message_id
    return unless settings.fetch(:address).match?(/\Aemail-smtp\.[a-z0-9-]+\.amazonaws\.com\z/)

    response.string.match(/\A250 Ok ([a-zA-Z0-9-]+)\s*\z/)&.[](1)
  end
end
