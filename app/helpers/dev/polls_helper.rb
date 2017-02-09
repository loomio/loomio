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

  def create_fake_stances(poll: )
    poll.poll_option_names.each do |name|
      (0..3).to_a.sample.times do
        poll.stances.create(poll: poll,
                           choice: name,
                           participant: fake_user,
                           reason: Faker::Hipster.sentence)
      end
    end
    poll.update_stance_data
  end

  def create_activity_items(discussion: , actor: )
    # create poll
    options = {poll: %w[apple turnip peach],
               check_in: %w[yip nup],
               proposal: %w[agree disagree abstain block]}

    Poll::TEMPLATES.keys.each do |poll_type|
      poll = Poll.new(poll_type: poll_type,
                      title: poll_type,
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: discussion)
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
      poll = Poll.new(poll_type: poll_type,
                      title: 'Which one?',
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: discussion)
      PollService.create(poll: poll, actor: actor)
      poll.update_attribute(:closing_at, 1.day.ago)

      # expire the poll
      PollService.expire_lapsed_polls
    end
  end

  def poll_created_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    user  = saved(fake_user)
    discussion.group.add_member! user
    PollService.create(poll: fake_poll(discussion: discussion, make_announcement: true, poll_type: poll_type), actor: actor)

    {discussion: discussion,
     observer: user,
     actor:    actor}
  end

  def poll_closing_soon_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    non_voter  = saved(fake_user)
    discussion.group.add_member! non_voter
    actor      = discussion.group.admins.first
    poll       = saved(create_fake_poll_with_stances(make_announcement: true,
                                                     author: actor,
                                                     poll_type: poll_type,
                                                     discussion: discussion,
                                                     closing_at: 1.day.from_now))
    PollService.create(poll: poll, actor: actor)
    PollService.publish_closing_soon

    { discussion: discussion,
      observer: non_voter,
      actor: actor,
      poll: poll}
  end

  def poll_closing_soon_with_vote_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved(create_fake_poll_with_stances(make_announcement: true,
                                                     author: actor,
                                                     poll_type: poll_type,
                                                     discussion: discussion,
                                                     closing_at: 1.day.from_now))
    voter      = poll.stances.last.participant
    discussion.group.add_member! voter
    PollService.create(poll: poll, actor: actor)
    PollService.publish_closing_soon

    { discussion: discussion,
      observer: voter,
      actor: actor,
      poll: poll}
  end

  def poll_expired_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion, poll_type: poll_type)
    poll.update_attribute(:closing_at, 1.day.ago)
    poll.discussion.group.add_member! poll.author
    PollService.expire_lapsed_polls
    { discussion: discussion,
      actor: actor,
      observer: poll.author,
      poll: poll}
  end

  def poll_outcome_created_scenario(poll_type:)
    discussion = saved(fake_discussion(group: create_group_with_members))
    actor      = discussion.group.admins.first
    observer   = fake_user
    discussion.group.add_member! observer
    poll       = create_fake_poll_with_stances(poll_type: poll_type,
                                               discussion: discussion,
                                               closed_at: 1.day.ago,
                                               closing_at: 1.day.ago)
    outcome    = fake_outcome(poll: poll, make_announcement: true)

    OutcomeService.create(outcome: outcome, actor: actor)
    { discussion: discussion,
      observer: observer,
      actor: actor,
      outcome: outcome,
      poll: poll}
  end

  def poll_missed_yesterday_scenario(poll_type:)
    scenario  = poll_expired_scenario(poll_type: poll_type)
    recipient = saved fake_user
    scenario[:discussion].group.add_member! recipient
    poll = scenario[:poll]
    poll.update(multiple_choice: poll_type.to_sym == :poll)
    choices =  [{poll_option_id: poll.poll_option_ids[0]}]
    choices += [{poll_option_id: poll.poll_option_ids[1]}] if poll.multiple_choice

    StanceService.create(stance: fake_stance(poll: poll, stance_choices_attributes: choices), actor: recipient)

    scenario.merge(recipient: recipient)
  end
end
