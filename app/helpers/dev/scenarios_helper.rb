module Dev::ScenariosHelper
  include Dev::FakeDataHelper
  
  def poll_created_scenario(params)
    group = create_group_with_members

    discussion = fake_discussion(group: group, title: "Some discussion")
    DiscussionService.create(discussion: discussion, actor: group.members.first)

    actor = group.admins.first
    user  = saved(fake_user(time_zone: "America/New_York"))

    group.add_member! user if !params[:guest]
    group.add_admin! user if params[:admin]

    poll = fake_poll(group: group,
                     discussion: params[:standalone] ? nil : discussion,
                     poll_type: params[:poll_type],
                     hide_results: (params[:hide_results] || :off),
                     wip: params[:wip],
                     anonymous: !!params[:anonymous])

    event = PollService.create(poll: poll, actor: actor)
    recipients = {recipient_emails: [user.email]}
    PollService.invite(poll: poll, params: recipients, actor: actor)

    {
      discussion: discussion,
      group: group,
      observer: user,
      poll: event.eventable,
      title: event.eventable.title,
      actor: actor,
    }
  end

  def poll_closed_scenario(params)
    observer = fake_user.tap(&:save!)
    group = create_group_with_members
    group.add_admin!(observer)
    poll = fake_poll(poll_type: params[:poll_type],
                     anonymous: !!params[:anonymous],
                     hide_results: (params[:hide_results] || :off),
                     group: group,
                     discussion: nil,
                     wip: params[:wip])

    event = PollService.create(poll: poll, actor: observer)
    Stance.where(poll_id: poll.id, participant_id: observer.id).delete_all

    stance = fake_stance(poll: poll)
    StanceService.create(stance: stance, actor: observer)

    PollService.close(poll: poll, actor: observer)

    {
      observer: observer,
      group: group,
      actor: observer,
      title: event.eventable.title,
      poll: event.eventable
    }
  end

  def poll_options_added_scenario(params)
    scenario = poll_stance_created_scenario(params)
    scenario[:poll].update(voter_can_add_options: true)
    PollService.add_options(poll: scenario[:poll],
                            actor: scenario[:real_actor],
                            params: {poll_option_names: option_names(2)[params[:poll_type]]})

    scenario.merge(observer: scenario[:voter])
  end

  def poll_options_added_author_scenario(params)
    scenario = poll_options_added_scenario(params)
    scenario.merge(observer: scenario[:poll].author)
  end

  def poll_user_mentioned_scenario(params)
    scenario = poll_created_scenario(params)
    voter    = saved(fake_user)
    group_member = saved(fake_user)
    scenario[:poll].group.add_member!(voter)
    scenario[:poll].group.add_member!(group_member)
    StanceService.create(stance: fake_stance(poll: scenario[:poll], reason: "<p><span class='mention' data-mention-id='#{group_member.username}'>@#{group_member.name}</span> </p>", reason_format: "html"), actor: voter)
    scenario[:actor] = voter

    scenario.merge(observer: group_member)
  end

  def poll_stance_created_scenario(params)
    scenario = poll_created_scenario(params)
    voter    = saved(fake_user)
    scenario[:poll].group.add_member!(voter)

    Stance.create!(
      participant: scenario[:poll].author, 
      poll: scenario[:poll], 
      admin: true, 
      reason_format: scenario[:poll].author.default_format)
    
    Stance.where(poll_id: scenario[:poll].id,
                 participant_id: scenario[:poll].author_id).update(volume: 'loud')
    event = StanceService.create(stance: fake_stance(poll: scenario[:poll]), actor: voter)
    scenario[:stance] = event.eventable
    scenario[:actor] = event.eventable.participant
    scenario[:real_actor] = voter

    scenario.merge(observer: scenario[:poll].author, voter: voter)
  end

  def poll_anonymous_scenario(params)
    scenario = poll_created_scenario(params)
    voter    = saved(fake_user)
    scenario[:poll].group.add_member!(voter)
    choices  =  [{poll_option_id: scenario[:poll].poll_option_ids[0]}]
    StanceService.create(stance: fake_stance(poll: scenario[:poll], stance_choices_attributes: choices), actor: voter)
    scenario[:actor] = voter

    scenario.merge(observer: scenario[:poll].author, voter: voter)
  end

  def poll_closing_soon_scenario(params)
    discussion = fake_discussion(group: create_group_with_members)
    non_voter  = saved(fake_user)
    discussion.group.add_member! non_voter
    actor      = discussion.group.admins.first
    DiscussionService.create(discussion: discussion, actor: actor)
    poll       = saved(create_fake_poll_with_stances(author: actor,
                                                     poll_type: params[:poll_type],
                                                     anonymous: !!params[:anonymous],
                                                     hide_results: (params[:hide_results] || :off),
                                                     discussion: discussion,
                                                     wip: params[:wip],
                                                     notify_on_closing_soon: params[:notify_on_closing_soon] || 'voters',
                                                     created_at: 6.days.ago,
                                                     closing_at: if params[:wip] then nil else 1.day.from_now end))

    PollService.create(poll: poll, actor: actor)
    PollService.invite(poll: poll, params: {recipient_user_ids: [non_voter.id]}, actor: actor)
    PollService.publish_closing_soon

    {
      discussion: discussion,
      group: discussion.group,
      observer: non_voter,
      actor: actor,
      poll: poll,
      title: poll.title
    }
  end

  def poll_reminder_scenario(params)
    discussion = fake_discussion(group: create_group_with_members)
    non_voter  = saved(fake_user)
    discussion.group.add_member! non_voter
    actor      = discussion.group.admins.first
    DiscussionService.create(discussion: discussion, actor: actor)
    poll       = saved(create_fake_poll_with_stances(author: actor,
                                                     poll_type: params[:poll_type],
                                                     anonymous: !!params[:anonymous],
                                                     hide_results: (params[:hide_results] || :off),
                                                     discussion: discussion,
                                                     wip: params[:wip],
                                                     notify_on_closing_soon: params[:notify_on_closing_soon] || 'voters',
                                                     created_at: 6.days.ago,
                                                     closing_at: if params[:wip] then nil else 1.day.from_now end))

    PollService.create(poll: poll, actor: actor)
    # Stance.create(poll: poll, participant: non_voter)
    PollService.invite(poll: poll, params: {recipient_user_ids: [non_voter.id]}, actor: actor)

    PollService.remind(poll: poll, params: {recipient_user_ids: [non_voter.id]}, actor: actor)

    {
      discussion: discussion,
      group: discussion.group,
      observer: non_voter,
      actor: actor,
      poll: poll,
      title: poll.title
    }
  end

  def poll_closing_soon_author_scenario(params)
    params[:notify_on_closing_soon] = 'author'
    scenario = poll_closing_soon_scenario(params)
    scenario.merge(observer: scenario[:poll].author)
  end

  def poll_closing_soon_with_vote_scenario(params)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    poll       = saved(create_fake_poll_with_stances(author: actor,
                                                     poll_type: params[:poll_type],
                                                     anonymous: !!params[:anonymous],
                                                     hide_results: (params[:hide_results] || :off),
                                                     notify_on_closing_soon: :voters,
                                                     discussion: discussion,
                                                     closing_at: if params[:wip] then nil else 1.day.from_now end))
    voter      = poll.stances.last.real_participant
    discussion.add_guest! voter, discussion.author
    PollService.create(poll: poll, actor: actor)
    PollService.invite(poll: poll, params: {recipient_user_ids: [voter.id]}, actor: actor)
    PollService.publish_closing_soon

    { 
      discussion: discussion,
      group: discussion.group,
      observer: voter,
      actor: actor,
      title: poll.title,
      poll: poll
    }
  end

  def poll_expired_scenario(params)
    scenario = poll_expired_author_scenario(params)
    scenario.merge(observer: scenario[:actor])
  end

  def poll_expired_author_scenario(params)
    discussion = fake_discussion(group: create_group_with_members)
    actor      = discussion.group.admins.first
    params[:discussion] = discussion
    poll       = create_fake_poll_with_stances(discussion: discussion,
                                               poll_type: params[:poll_type],
                                               anonymous: !!params[:anonymous],
                                               hide_results: (params[:hide_results] || :off))
    poll.update_attribute(:closing_at, 1.day.ago)
    poll.discussion.group.add_member! poll.author
    Events::PollCreated.publish!(poll, poll.author)
    PollService.expire_lapsed_polls
    { discussion: discussion,
      group: discussion.group,
      actor: actor,
      observer: poll.author,
      title: poll.title,
      poll: poll}
  end

  def poll_outcome_created_scenario(params)
    discussion = saved(fake_discussion(group: create_group_with_members))
    actor      = discussion.group.admins.first
    observer   = fake_user
    discussion.group.add_member! observer
    poll       = create_fake_poll_with_stances(poll_type: params[:poll_type],
                                               anonymous: !!params[:anonymous],
                                               hide_results: (params[:hide_results] || :off),
                                               discussion: discussion,
                                               closed_at: 1.day.ago,
                                               closing_at: 1.day.ago)
    outcome    = fake_outcome(poll: poll)
    poll.create_missing_created_event!

    OutcomeService.create(outcome: outcome, actor: actor, params: {recipient_emails: [observer.email]})

    { discussion: discussion,
      group: discussion.group,
      observer: observer,
      actor: actor,
      outcome: outcome,
      title: poll.title,
      poll: poll}
  end

  def poll_outcome_review_due_scenario(params)
    discussion = saved(fake_discussion(group: create_group_with_members))
    actor      = discussion.group.admins.first
    observer   = fake_user
    discussion.group.add_member! observer
    poll       = create_fake_poll_with_stances(poll_type: params[:poll_type],
                                               anonymous: !!params[:anonymous],
                                               hide_results: (params[:hide_results] || :off),
                                               discussion: discussion,
                                               closed_at: 1.day.ago,
                                               closing_at: 1.day.ago)
    outcome    = fake_outcome(poll: poll, author: poll.author)

    poll.create_missing_created_event!
    Events::OutcomeReviewDue.publish!(outcome)
    # OutcomeService.create(outcome: outcome, actor: actor, params: {recipient_emails: [observer.email]})

    { discussion: discussion,
      group: discussion.group,
      observer: poll.author,
      actor: actor,
      outcome: outcome,
      title: poll.title,
      poll: poll}
  end

  def poll_catch_up_scenario(params)
    discussion = saved(fake_discussion(group: create_group_with_members))
    scenario  = poll_expired_scenario(params)
    observer = fake_user.tap(&:save!)
    observer.email_catch_up_day = 7
    discussion.group.add_member! observer
    scenario[:discussion].group.add_member! observer
    poll = scenario[:poll]
    choices =  [{poll_option_id: poll.poll_option_ids[0]}]

    StanceService.create(stance: fake_stance(poll: poll, stance_choices_attributes: choices), actor: observer)
    UserMailer.catch_up(observer.id).deliver_now

    scenario.merge(observer: observer)
  end
  
  def alternative_poll_option_selection(poll_option_ids, i)
    poll_option_ids.each_with_index.map {|id, j| {poll_option_id: id, score: (i+j)%3}}
  end

    def saved(obj)
    obj.tap(&:save!)
  end


end
