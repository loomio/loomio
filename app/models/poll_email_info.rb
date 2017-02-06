class PollEmailInfo
  include Routing
  attr_reader :recipient, :poll, :actor, :action_name

  def send_reason
    # TODO: determine why this recipient is receiving this email
    # PollEmailService.reason_for(@poll, @recipient) ????
    "some reason"
  end

  def poll_type
    @poll.poll_type
  end

  def initialize(recipient:, poll:, actor:, action_name:)
    @recipient   = recipient
    @poll        = poll
    @actor       = actor
    @action_name = action_name
  end

  def links
    {
      unsubscribe: unsubscribe_url,
      target:      target_url
    }
  end

  private

  def unsubscribe_url
    email_preferences_url utm_hash.merge(unsubscribe_token: recipient.unsubscribe_token)
  end

  def target_url
    poll_url poll, utm_hash
  end

  def utm_hash
    { utm_medium: 'email', utm_campaign: 'poll_mailer', utm_source: action_name }
  end
end
