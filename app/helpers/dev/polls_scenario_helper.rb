module Dev::PollsScenarioHelper
  private

  def poll_created_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor = discussion.group.admins.first
    user  = saved(fake_user(time_zone: "America/New_York"))
    discussion.group.add_member! user
    poll = fake_poll(discussion: discussion, poll_type: poll_type)
    event = PollService.create(poll: poll, actor: actor)
    recipients = {user_ids: [user.id], emails: [user.email]}
    announcement_params = { kind: "poll_announced", recipients: recipients }
    AnnouncementService.create(model: poll, params: announcement_params, actor: actor)

    {discussion: discussion,
     observer: user,
     poll:     event.eventable,
     actor:    actor,
     params: {share: true}}
  end

  def poll_share_scenario(poll_type:)
    observer = saved fake_user
    event = PollService.create(poll: fake_poll(poll_type: poll_type, discussion: nil), actor: observer)
     {observer: observer,
     actor: observer,
     poll: event.eventable,
     params: {share: true}}
  end

  def poll_closed_scenario(poll_type:)
    scenario = poll_share_scenario(poll_type: poll_type)
    PollService.close(poll: scenario[:poll], actor: scenario[:actor])

    {observer: scenario[:observer],
     poll:     scenario[:poll]}
  end

  def poll_options_added_scenario(poll_type:)
    scenario = poll_stance_created_scenario(poll_type: poll_type)
    PollService.add_options(poll: scenario[:poll],
                            actor: scenario[:actor],
                            params: {poll_option_names: option_names(2)[poll_type]})

    scenario.merge(observer: scenario[:voter])
  end

  def poll_options_added_author_scenario(poll_type:)
    scenario = poll_options_added_scenario(poll_type: poll_type)
    scenario.merge(observer: scenario[:poll].author)
  end

  def poll_created_as_logged_out_scenario(poll_type:)
    scenario = poll_created_as_visitor_scenario(poll_type: poll_type)
    scenario[:poll].update(anyone_can_participate: true)

    {poll: scenario[:poll],
     actor: scenario[:actor]}
  end

  def poll_created_as_visitor_scenario(poll_type:)
    actor = saved fake_user
    poll = fake_poll(poll_type: poll_type, discussion: nil)
    event = PollService.create(poll: poll, actor: actor)
    poll.update(anyone_can_participate: true)
    membership = poll.guest_group.memberships.create(user: fake_user(email_verified: false))

    {poll: poll,
     actor: actor,
     params: {membership_token: membership.token}}
  end

  def poll_edited_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved fake_poll(discussion: discussion, poll_type: poll_type)
    observer   = saved(fake_user)
    discussion.group.add_admin! actor
    discussion.group.add_member! observer

    StanceService.create(stance: fake_stance(poll: poll), actor: observer)
    PollService.update(poll: poll, params: { title: "New title" }, actor: actor)
    recipients = {user_ids: [observer.id], emails: [observer.email]}
    announcement_params = { kind: "poll_announced", recipients: recipients }
    AnnouncementService.create(model: poll, params: announcement_params, actor: actor)

    {discussion: discussion,
     observer: observer,
     actor:    actor}
  end

  def poll_stance_created_scenario(poll_type:)
    scenario = poll_created_scenario(poll_type: poll_type)
    voter    = saved(fake_user)
    scenario[:poll].update(notify_on_participate: true)
    scenario[:poll].group.add_member!(voter)
    choices  =  [{poll_option_id: scenario[:poll].poll_option_ids[0]}]
    StanceService.create(stance: fake_stance(poll: scenario[:poll], stance_choices_attributes: choices), actor: voter)

    scenario.merge(observer: scenario[:poll].author, voter: voter)
  end

  def poll_anonymous_scenario(poll_type:)
    scenario = poll_created_scenario(poll_type: poll_type)
    voter    = saved(fake_user)
    scenario[:poll].update(notify_on_participate: true, anonymous: true)
    scenario[:poll].group.add_member!(voter)
    choices  =  [{poll_option_id: scenario[:poll].poll_option_ids[0]}]
    StanceService.create(stance: fake_stance(poll: scenario[:poll], stance_choices_attributes: choices), actor: voter)

    scenario.merge(observer: scenario[:poll].author, voter: voter)
  end

  def poll_closing_soon_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    non_voter  = saved(fake_user)
    discussion.group.add_member! non_voter
    actor      = discussion.group.admins.first
    poll       = saved(create_fake_poll_with_stances(author: actor,
                                                     poll_type: poll_type,
                                                     discussion: discussion,
                                                     closing_at: 1.day.from_now))

    PollService.create(poll: poll, actor: actor)
    recipients = {user_ids: [non_voter.id], emails: [non_voter.email]}
    announcement_params = { kind: "poll_announced", recipients: recipients }
    AnnouncementService.create(model: poll, params: announcement_params, actor: actor)

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
    poll       = saved(create_fake_poll_with_stances(author: actor,
                                                     poll_type: poll_type,
                                                     discussion: discussion,
                                                     closing_at: 1.day.from_now))
    voter      = poll.stances.last.participant
    discussion.group.add_member! voter
    PollService.create(poll: poll, actor: actor)
    PollService.publish_closing_soon
    recipients = {user_ids: [voter.id], emails: [voter.email]}
    announcement_params = { kind: "poll_announced", recipients: recipients }
    AnnouncementService.create(model: poll, params: announcement_params, actor: actor)

    { discussion: discussion,
      observer: voter,
      actor: actor,
      poll: poll}
  end

  def poll_expired_scenario(poll_type:)
    scenario = poll_expired_author_scenario(poll_type: poll_type)
    scenario.merge(observer: scenario[:actor])
  end

  def poll_expired_author_scenario(poll_type:)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = create_fake_poll_with_stances(discussion: discussion, poll_type: poll_type)
    poll.update_attribute(:closing_at, 1.day.ago)
    poll.discussion.group.add_member! poll.author
    Events::PollCreated.publish!(poll, poll.author)
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
    outcome    = fake_outcome(poll: poll)

    OutcomeService.create(outcome: outcome, actor: actor)
    recipients = {user_ids: [observer.id], emails: [observer.email]}
    announcement_params = { kind: "outcome_announced", recipients: recipients }
    AnnouncementService.create(model: outcome, params: announcement_params, actor: actor)

    { discussion: discussion,
      observer: observer,
      actor: actor,
      outcome: outcome,
      poll: poll}
  end

  def poll_catch_up_scenario(poll_type:)
    discussion = saved(fake_discussion(group: create_group_with_members))
    scenario  = poll_expired_scenario(poll_type: poll_type)
    observer = saved fake_user
    observer.email_catch_up = true
    discussion.group.add_member! observer
    scenario[:discussion].group.add_member! observer
    poll = scenario[:poll]
    poll.update(multiple_choice: poll_type.to_sym == :poll)
    choices =  [{poll_option_id: poll.poll_option_ids[0]}]
    choices += [{poll_option_id: poll.poll_option_ids[1]}] if poll.multiple_choice

    StanceService.create(stance: fake_stance(poll: poll, stance_choices_attributes: choices), actor: observer)
    UserMailer.catch_up(observer.id).deliver_now

    scenario.merge(observer: observer)
  end

  def poll_notifications_scenario(poll_type:)
    discussion = saved fake_discussion(group: create_group_with_members)
    observer   = saved fake_user
    admin      = saved fake_user
    discussion.group.add_member! observer
    discussion.group.add_admin! admin
    admin_poll = fake_poll(discussion: discussion, poll_type: poll_type, closing_at: 24.hours.from_now)
    observer_poll = saved fake_poll(discussion: discussion, author: observer, poll_type: poll_type)

    # poll_created
    PollService.create(poll: admin_poll, actor: admin)

    # poll closing soon
    PollService.publish_closing_soon # (closing soon for admin_poll)

    # poll_edited
    StanceService.create(stance: fake_stance(poll: admin_poll), actor: observer)
    PollService.update(poll: admin_poll, params: { title: "New title" }, actor: admin)

    # poll expired
    observer_poll.update_attribute(:closing_at, 1.day.ago)
    admin_poll.update_attribute(:closing_at, 1.day.ago)
    PollService.expire_lapsed_polls # (closes observer_poll)

    # outcome_created
    OutcomeService.create(outcome: fake_outcome(poll: admin_poll.reload), actor: admin)

    {discussion: discussion,
     observer:   observer,
     poll:       observer_poll,
     admin:      admin}
  end

  def poll_with_guest_scenario(poll_type:)
    group = create_group_with_members
    user  = saved fake_user
    another_user = saved fake_user
    group.add_member!(user)
    group.add_member!(another_user)

    poll = fake_poll(poll_type: poll_type, discussion: fake_discussion(group: group))
    PollService.create(poll: poll, actor: another_user)
    Stance.create(poll: poll, participant: user, choice: poll.poll_option_names.first)
    poll.update_stance_data

    GroupInviter.new(
      group:    poll.guest_group,
      inviter:  user,
      user_ids: [saved(fake_user).id],
      emails:   ['bill@example.com']
    ).invite!

    {group: group,
     poll: poll,
     observer: user}
  end

  def poll_with_guest_as_author_scenario(poll_type:)
    scenario = poll_with_guest_scenario(poll_type: poll_type)
    scenario.merge(observer: scenario[:poll].author)
  end

  def alternative_poll_option_selection (poll_option_ids, i)
    poll_option_ids.each_with_index.map {|id, j| {poll_option_id: id, score: (i+j)%3}}
  end

  def poll_meeting_populated_scenario(poll_type:)
    user = saved fake_user

    poll = fake_poll(poll_type: poll_type, option_count: 5)
    PollService.create(poll: poll, actor: user)

    5.times do |i|
      choices = alternative_poll_option_selection(poll.poll_option_ids, i)
      stance = saved fake_stance(poll:poll, participant:saved(fake_user), stance_choices_attributes: choices)
    end

    { poll: poll,
      observer: user}
  end
end
