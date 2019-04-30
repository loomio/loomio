class PollEmailInfo
  include Routing
  attr_reader :recipient, :poll, :actor, :action_name, :eventable, :event

  def send_reason
    # TODO: determine why this recipient is receiving this email
    # PollEmailService.reason_for(@poll, @recipient) ????
    "some reason"
  end

  def login_token(redirect_path: poll_path(@poll))
    @token ||= @recipient.login_tokens.create!(redirect: redirect_path)
  end

  def initialize(recipient:, event:, action_name:)
    @recipient   = recipient
    @event       = event
    @eventable   = event.eventable
    @poll        = event.eventable.poll
    @action_name = action_name
  end

  def actor
    @actor ||= if @eventable.is_a?(Stance)
      @eventable.participant_for_client
    else
      @event.user || LoggedOutUser.new
    end
  end

  def recipient_stance
    @recipient_stance ||= @poll.stances.latest.find_by(participant: @recipient)
  end

  def poll_options
    @poll.ordered_poll_options
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

  def target_url(args = {})
    args.merge!(membership_token: membership.token) if membership
    polymorphic_url(poll, utm_hash(args))
  end

  def unsubscribe_url
    poll_unsubscribe_url poll, utm_hash.merge(unsubscribe_token: recipient.unsubscribe_token)
  end

  def utm_hash(args = {})
    {
      utm_medium: 'email',
      utm_campaign: 'poll_mailer',
      utm_source: action_name
    }.merge(args)
  end

  private

  def membership
    @membership ||= poll.guest_group.memberships.find_by(user: recipient)
  end

end
