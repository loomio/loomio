class PollEmailInfo
  include Routing
  attr_reader :recipient, :poll, :actor, :action_name

  def send_reason
    # TODO: determine why this recipient is receiving this email
    # PollEmailService.reason_for(@poll, @recipient) ????
    "some reason"
  end

  def initialize(recipient:, poll:, actor: nil, action_name:)
    @recipient   = recipient
    @poll        = poll
    @actor       = actor || LoggedOutUser.new
    @action_name = action_name
  end

  def recipient_stance
    @recipient_stance ||= @poll.stances.latest.find_by(participant: @recipient)
  end

  def poll_type
    @poll.poll_type
  end

  def time_zone
    @recipient.time_zone || @poll.custom_fields['time_zone']
  end

  def formatted_time_zone
    ActiveSupport::TimeZone[time_zone].to_s if time_zone
  end

  def outcome
    @poll.current_outcome
  end

  def choice_img
    prefix = @poll.multiple_choice ? 'check' : 'radio'
    "poll_mailer/#{prefix}_off.png"
  end

  def links
    {
      unsubscribe: unsubscribe_url,
      target:      target_url
    }
  end

  def utm_hash(args = {})
    {
      utm_medium: 'email',
      utm_campaign: 'poll_mailer',
      utm_source: action_name,
      participation_token: @recipient.participation_token
    }.merge(args)
  end

  private

  def unsubscribe_url
    email_preferences_url utm_hash.merge(unsubscribe_token: recipient.unsubscribe_token)
  end

  def target_url
    poll_url poll, utm_hash
  end
end
