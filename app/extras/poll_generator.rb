PollGenerator = Struct.new(:poll_type) do

  def generate!
    return unless AppConfig.poll_templates.keys.include?(poll_type.to_s)
    poll = Poll.create(default_params)
    poll.create_guest_group
    poll.save!
    send(:"#{poll_type}_stances_for", poll)
    poll.update_stance_data
    poll.invite_guest!(email: User.demo_bot.email)
    poll
  end

  private

  def default_params
    {
      poll_type:               poll_type,
      author:                  User.helper_bot,
      title:                   I18n.t(:"poll_generator.#{poll_type}.title"),
      details:                 I18n.t(:"poll_generator.#{poll_type}.details"),
      closing_at:              1.day.from_now,
      example:                 true,
      poll_option_names:       AppConfig.poll_templates.dig(poll_type, 'poll_options_attributes').map do |attr|
        attr['name']
      end
    }.merge(send(:"#{poll_type}_params"))
  end

  def proposal_params
    {}
  end

  def proposal_stances_for(poll)
    generate_stance_for(poll, index: 0, reason: "I love them, and think they'll both be great!", choice: "agree")
    generate_stance_for(poll, index: 1, reason: "Solid additions", choice: "agree")
    generate_stance_for(poll, index: 2, reason: "100% agree, they're awesome.", choice: "agree")
    generate_stance_for(poll, index: 3, reason: "I love them, and think they'll both be great!", choice: "agree")
    generate_stance_for(poll, index: 4, reason: "I haven't really interacted with either, but I trust the team", choice: "abstain")
    generate_stance_for(poll, index: 5, reason: "I'd feel more comfortable if we kept them as interns for another month or so", choice: "disagree")
  end

  def count_params
    {}
  end

  def count_stances_for(poll)
    generate_stance_for(poll, index: 0, reason: "", choice: "yes")
    generate_stance_for(poll, index: 1, reason: "I would love to help, but I'll be on vacation for the week before", choice: "no")
    generate_stance_for(poll, index: 2, reason: "I'd love to help!", choice: "yes")
    generate_stance_for(poll, index: 3, reason: "Sorry, not me.. too busy at the moment", choice: "no")
    generate_stance_for(poll, index: 4, reason: "Yes!", choice: "yes")
    generate_stance_for(poll, index: 5, reason: "Happy to help :)", choice: "yes")
  end

  def poll_params
    {
      poll_option_names: ["No gluten for me", "I can't eat meat", "I'm allergic to shellfish", "I'll eat anything!"],
      multiple_choice: true
    }
  end

  def poll_stances_for(poll)
    generate_stance_for(poll, index: 0, reason: "", choice: "No gluten for me")
    generate_stance_for(poll, index: 1, reason: "Looking forward to it!", choice: "No gluten for me")
    generate_stance_for(poll, index: 2, reason: "", choice: "No gluten for me")
    generate_stance_for(poll, index: 3, reason: "See you then!", choice: "I'm allergic to shellfish")
    generate_stance_for(poll, index: 4, reason: "", choice: "I'll eat anything!")
    generate_stance_for(poll, index: 5, reason: "", choice: "")
  end

  def dot_vote_params
    {
      poll_option_names: ["Product Development", "Invest in our team", "Marketing", "Growing our Consulting Business", "Community / Customer Engagement"],
      custom_fields: { dots_per_person: 8 }
    }
  end

  def dot_vote_stances_for(poll)
    generate_stance_for(poll, index: 0, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[1], score: 2 },
      { poll_option_id: poll.poll_option_ids[2], score: 3 },
      { poll_option_id: poll.poll_option_ids[3], score: 3 }
    ])
    generate_stance_for(poll, index: 1, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0], score: 7 },
      { poll_option_id: poll.poll_option_ids[4], score: 1 }
    ])
    generate_stance_for(poll, index: 2, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0], score: 1 },
      { poll_option_id: poll.poll_option_ids[1], score: 3 },
      { poll_option_id: poll.poll_option_ids[2], score: 1 },
      { poll_option_id: poll.poll_option_ids[3], score: 1 },
      { poll_option_id: poll.poll_option_ids[4], score: 2 }
    ])
  end

  def meeting_params
    {
      poll_option_names: [
        2.days.from_now.beginning_of_hour.iso8601,
        3.days.from_now.beginning_of_hour.iso8601,
        7.days.from_now.beginning_of_hour.iso8601
      ]
    }
  end

  def meeting_stances_for(poll)
    generate_stance_for(poll, index: 0, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[2] }
    ])
    generate_stance_for(poll, index: 1, reason: "Sorry, this week is crazy for me!", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] }
    ])
    generate_stance_for(poll, index: 2, reason: "I'm free whenever", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[1] },
      { poll_option_id: poll.poll_option_ids[2] }
    ])
    generate_stance_for(poll, index: 3, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[1] },
      { poll_option_id: poll.poll_option_ids[2] }
    ])
    generate_stance_for(poll, index: 4, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0] },
      { poll_option_id: poll.poll_option_ids[1] }
    ])
  end

  def ranked_choice_params
    {
      poll_option_names: participant_names,
      custom_fields: { minimum_stance_choices: 3 }
    }
  end

  def ranked_choice_stances_for(poll)
    generate_stance_for(poll, index: 0, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[0], score: 1 },
      { poll_option_id: poll.poll_option_ids[1], score: 2 },
      { poll_option_id: poll.poll_option_ids[2], score: 3 }
    ])
    generate_stance_for(poll, index: 1, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[3], score: 1 },
      { poll_option_id: poll.poll_option_ids[4], score: 2 },
      { poll_option_id: poll.poll_option_ids[5], score: 3 }
    ])
    generate_stance_for(poll, index: 2, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[4], score: 1 },
      { poll_option_id: poll.poll_option_ids[1], score: 2 },
      { poll_option_id: poll.poll_option_ids[5], score: 3 }
    ])
    generate_stance_for(poll, index: 3, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[2], score: 1 },
      { poll_option_id: poll.poll_option_ids[1], score: 2 },
      { poll_option_id: poll.poll_option_ids[3], score: 3 }
    ])
    generate_stance_for(poll, index: 4, reason: "", stance_choices_attributes: [
      { poll_option_id: poll.poll_option_ids[5], score: 1 },
      { poll_option_id: poll.poll_option_ids[0], score: 2 },
      { poll_option_id: poll.poll_option_ids[2], score: 3 }
    ])
  end

  def generate_stance_for(poll, index: 0, reason:, choice: nil, stance_choices_attributes: [])
    Stance.create!(
      poll:        poll,
      participant: generate_participant_for(poll, index),
      stance_choices_attributes: stance_choices_attributes,
      reason:      reason,
      choice:      choice
    )
  end

  def generate_participant_for(poll, index)
    User.find_or_create_by(participant_params_for(index)).tap do |user|
      poll.guest_group.add_member! user
    end
  end

  def participant_params_for(index)
    {
      name:  participant_names[index],
      email: "#{participant_names[index].split(' ').first.downcase}@example.com"
    }
  end

  def participant_names
    [
      "Lorna Ritchie Jr.",
      "Rashawn Walsh",
      "Mable Marvin",
      "Lelah Lindgren",
      "Rick Kuhn",
      "Jamie Wright"
    ].freeze
  end
end
