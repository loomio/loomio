module Dev::PollsScenarioHelper
  def observe_scenario(scenario_name:, poll_type:, view_email: false, view_as_observer: true)
    scenario = send(:"#{scenario_name}_scenario", poll_type: poll_type)
    sign_in(scenario[:observer]) if view_as_observer
    if view_email
      last_email to: scenario[:observer]
    else
      redirect_to poll_url(scenario[:poll])
    end
  end

  def poll_created_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    user  = saved(fake_user)
    discussion.group.add_member! user
    event = PollService.create(poll: fake_poll(discussion: discussion, make_announcement: true, poll_type: poll_type), actor: actor)

    {discussion: discussion,
     observer: user,
     poll:     event.eventable,
     actor:    actor}
  end

  def poll_edited_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved fake_poll(discussion: discussion, make_announcement: true, poll_type: poll_type)
    observer   = saved(fake_user)
    discussion.group.add_admin! actor
    discussion.group.add_member! observer

    StanceService.create(stance: fake_stance(poll: poll), actor: observer)
    PollService.update(poll: poll, params: { make_announcement: true, title: "New title" }, actor: actor)

    {discussion: discussion,
     observer: observer,
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

  def poll_closing_soon_author_scenario(poll_type:)
    scenario = poll_closing_soon_scenario(poll_type: poll_type)
    scenario.merge(observer: scenario[:poll].author)
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
    observer = saved fake_user
    scenario[:discussion].group.add_member! observer
    poll = scenario[:poll]
    poll.update(multiple_choice: poll_type.to_sym == :poll)
    choices =  [{poll_option_id: poll.poll_option_ids[0]}]
    choices += [{poll_option_id: poll.poll_option_ids[1]}] if poll.multiple_choice

    StanceService.create(stance: fake_stance(poll: poll, stance_choices_attributes: choices), actor: observer)
    UserMailer.missed_yesterday(observer).deliver_now

    scenario.merge(observer: observer)
  end

  def poll_notifications_scenario(poll_type:)
    discussion = saved fake_discussion(group: create_group_with_members)
    observer   = saved fake_user
    admin      = saved fake_user
    discussion.group.add_member! observer
    discussion.group.add_admin! admin
    admin_poll = fake_poll(discussion: discussion, make_announcement: true, poll_type: poll_type, closing_at: 24.hours.from_now)
    observer_poll = saved fake_poll(discussion: discussion, author: observer, make_announcement: true, poll_type: poll_type)

    # poll_created
    PollService.create(poll: admin_poll, actor: admin)

    # poll closing soon
    PollService.publish_closing_soon # (closing soon for admin_poll)

    # poll_edited
    StanceService.create(stance: fake_stance(poll: admin_poll), actor: observer)
    PollService.update(poll: admin_poll, params: { make_announcement: true, title: "New title" }, actor: admin)

    # poll expired
    observer_poll.update_attribute(:closing_at, 1.day.ago)
    admin_poll.update_attribute(:closing_at, 1.day.ago)
    PollService.expire_lapsed_polls # (closes observer_poll)

    # outcome_created
    OutcomeService.create(outcome: fake_outcome(poll: admin_poll.reload, make_announcement: true), actor: admin)

    {discussion: discussion,
     observer:   observer,
     poll:       observer_poll,
     admin:      admin}
  end
end
