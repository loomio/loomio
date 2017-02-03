class PollEmailInfo
  include Routing
  attr_reader :poll, :recipient, :actor, :action_name

  def send_reason
    # TODO: determine why this recipient is receiving this email
    # PollEmailService.reason_for(@poll, @recipient) ????
    "some reason"
  end

  def poll_type
    @poll.poll_type
  end

  def initialize(poll:, actor:, recipient:, action_name:, utm: {})
    @poll = poll
    @actor = actor
    @recipient = recipient
    @action_name = action_name
    @utm = utm
  end

  def links
    {
      unsubscribe: unsubscribe_url,
      target:      target_url
    }
  end

  private

  def unsubscribe_url
    email_preferences_url @utm.merge(unsubscribe_token: @recipient.unsubscribe_token)
  end

  def target_url
    if @poll.discussion
      discussion_url @poll.discussion, @utm
    else
      # TODO: poll_url poll, utm_hash
    end
  end
end
