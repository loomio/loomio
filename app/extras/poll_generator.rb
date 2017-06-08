PollGenerator = Struct.new(:poll_type) do

  def generate!
    return unless Poll::TEMPLATES.keys.include?(poll_type.to_s)
    poll = Poll.create(poll_params)
    poll.community_of_type(:email, build: true)
    poll.save!
    poll.community_of_type(:email).visitors.create(email: User.demo_bot.email)
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
    {}
  end

  def count
    {}
  end

  def poll
    {
      poll_option_names: ["No gluten for me", "I can't eat meat", "I'm allergic to shellfish", "I'll eat anything!"],
      multiple_choice: true
    }
  end

  def dot_vote
    {
      poll_option_names: ["Product development", "Customer acquisition", "Customer support", "Enterprise Sales", "Team growth"],
      custom_fields: { dots_per_person: 8 }
    }
  end

  def meeting
    {
      poll_option_names: [
        2.days.from_now.beginning_of_hour.iso8601,
        3.days.from_now.beginning_of_hour.iso8601,
        7.days.from_now.beginning_of_hour.iso8601
      ]
    }
  end
end
