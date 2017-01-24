class PollEmailInfo
  include Routing
  attr_reader :poll, :recipient

  def initialize(poll:, recipient:, utm: {})
    @poll, @recipient, @utm = poll, recipient, utm
  end

  # creates a hash which has a PollOption as a key, and a list of stance
  # choices associated with that PollOption as a value
  def grouped_stance_options
    @grouped_stance_options ||=
      @poll.stance_choices
           .includes(:poll_option, stance: :participant)
           .to_a.group_by(&:poll_option)
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
