PollGenerator = Struct.new(:poll_type) do

  def generate!
    return unless Poll::TEMPLATES.keys.include?(poll_type.to_s)
    poll = Poll.create(poll_params)
    poll.community_of_type(:email, build: true)
    poll.save!
    poll.community_of_type(:email).visitors.create(email: User.helper_bot.email)
    poll
  end

  private

  def poll_params
    {
      poll_type:               poll_type,
      author:                  User.helper_bot,
      title:                   I18n.t(:"poll_generator.#{poll_type}.title"),
      details:                 I18n.t(:"poll_generator.#{poll_type}.details"),
      poll_options_attributes: Poll::TEMPLATES.dig(poll_type, 'poll_options_attributes'),
      closing_at:              1.day.from_now,
      example:                 true
    }.merge(send(poll_type.to_s))
  end

  def proposal
    {
    }
  end

  def count
    {
    }
  end

  def poll
    {
    }
  end

  def dot_vote
    {
    }
  end

  def meeting
    {
    }
  end
end
