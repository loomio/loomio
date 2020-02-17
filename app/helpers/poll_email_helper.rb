module PollEmailHelper
  include Routing

  # def login_token(redirect_path: poll_path(@poll))
  #   @token ||= @recipient.login_tokens.create!(redirect: redirect_path)
  # end

  def login_token(recipient, redirect_path)
    recipient.login_tokens.create!(redirect: redirect_path)
  end

  def actor(event)
    @actor ||= if event.eventable.is_a?(Stance)
      event.eventable.participant_for_client
    else
      event.user || LoggedOutUser.new
    end
  end

  def recipient_stance(recipient, poll)
    poll.stances.latest.find_by(participant: recipient)
  end

  def time_zone(recipient, poll)
    recipient.time_zone || poll.time_zone
  end

  def formatted_time_zone(recipient, poll)
    time_zone = time_zone(recipient, poll)
    ActiveSupport::TimeZone[time_zone].to_s if time_zone
  end

  def choice_img(poll)
    prefix = poll.multiple_choice ? 'check' : 'radio'
    "poll_mailer/#{prefix}_off.png"
  end

  def target_url(poll:, recipient:, args: {})
    membership = membership(poll, recipient)
    args.merge!(membership_token: membership.token) if membership
    polymorphic_url(poll, poll_mailer_utm_hash(args))
  end

  def unsubscribe_url(poll, recipient, action_name)
    poll_unsubscribe_url poll, poll_mailer_utm_hash(action_name).merge(unsubscribe_token: recipient.unsubscribe_token)
  end

  def poll_mailer_utm_hash(args = {}, action_name)
    {
      utm_medium: 'email',
      utm_campaign: 'poll_mailer',
      utm_source: action_name
    }.merge(args)
  end

  private

  def membership(poll, recipient)
    poll.guest_group.memberships.find_by(user: recipient)
  end

end
