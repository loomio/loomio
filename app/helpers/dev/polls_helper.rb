module Dev::PollsHelper
  include Dev::FakeDataHelper

  private

  def create_fake_poll_with_stances(args = {})
    poll = saved fake_poll(args)
    create_fake_stances(poll: poll)
    poll
  end

  def create_group_with_members
    group = saved(fake_group)
    group.add_admin!(saved(fake_user))
    group.add_member!(saved(fake_user))
    group
  end

  def create_fake_poll_in_group(args = {})
    saved(build_fake_poll_in_group)
  end

  def create_fake_stances(poll:)
    (2..4).to_a.sample.times do
      u = fake_user
      poll.group.add_member!(u) if poll.group
      index = 0
      choice = if poll.minimum_stance_choices > 1
        poll.poll_options.sample(poll.minimum_stance_choices).map do |option|
          [option.name, index+=1]
        end.to_h
      else
        poll.poll_option_names.sample
      end
      poll.stances.create!(participant: u,
                           poll: poll,
                           choice: choice,
                           reason: [Faker::Hipster.sentence, ""].sample)
    end
    poll.update_stance_data
  end

  def create_activity_items(discussion: , actor: )
    # create poll
    options = {poll: %w[apple turnip peach],
               count: %w[yes no],
               proposal: %w[agree disagree abstain block],
               dot_vote: %w[birds bees trees],
               meeting: %w[2009-1-1]}
    custom_fields = { dot_vote: { dots_per_person: 8 } }

    AppConfig.poll_templates.keys.each do |poll_type|
      poll = Poll.new({poll_type: poll_type,
                       title: poll_type,
                       details: 'fine print',
                       poll_option_names: options[poll_type.to_sym],
                       discussion: discussion}.merge(Hash(custom_fields[poll_type.to_sym])))
      PollService.create(poll: poll, actor: actor)

      # edit the poll
      PollService.update(poll: poll, params: {title: 'choose!'}, actor: actor)

      # vote on the poll
      stance = Stance.new(poll: poll,
                          choice: poll.poll_option_names.first,
                          reason: 'democracy is in my shoes')
      StanceService.create(stance: stance, actor: actor)

      # close the poll
      PollService.close(poll: poll, actor: actor)

      # set an outcome
      outcome = Outcome.new(poll: poll, statement: 'We all voted')
      OutcomeService.create(outcome: outcome, actor: actor)

      # create poll
      poll = Poll.new({poll_type: poll_type,
                      title: 'Which one?',
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: discussion}.merge(Hash(custom_fields[poll_type.to_sym])))
      PollService.create(poll: poll, actor: actor)
      poll.update_attribute(:closing_at, 1.day.ago)

      # expire the poll
      PollService.expire_lapsed_polls
    end
  end
end
