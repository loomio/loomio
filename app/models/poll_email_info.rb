class PollEmailInfo
  include Routing
  attr_reader :recipient, :poll, :actor, :action_name, :eventable, :event

  def send_reason
    # TODO: determine why this recipient is receiving this email
    # PollEmailService.reason_for(@poll, @recipient) ????
    "some reason"
  end

  def login_token
    @token ||= @recipient.login_tokens.create!(redirect: poll_path(@poll))
  end

  def initialize(recipient:, event:, action_name:)
    @recipient   = recipient
    @event       = event
    @poll        = event.poll
    @eventable   = event.eventable
    @action_name = action_name
  end

  def actor
    @actor ||= if @event.eventable.is_a?(Stance)
      @event.eventable.participant
    else
      @event.user || LoggedOutUser.new
    end
  end

  def recipient_stance
    @recipient_stance ||= @poll.stances.latest.find_by(participant: @recipient)
  end

  def poll_options
    if @poll.dates_as_options
      @poll.poll_options.order(name: :asc)
    else
      @poll.poll_options
    end
  end

  def poll_type
    @poll.poll_type
  end

  def undecided
    @undecided ||= @poll.undecided
  end

  def undecided_max
    20
  end

  def time_zone
    @recipient.time_zone || @poll.time_zone
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
      invitation_token: @recipient.token
    }.merge(args)
  end

  private

  def unsubscribe_url
    poll_unsubscribe_url poll, utm_hash.merge(unsubscribe_token: recipient.unsubscribe_token)
  end

  def target_url
    poll_url poll, utm_hash
  end
end
