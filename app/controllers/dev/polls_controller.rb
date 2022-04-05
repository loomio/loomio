class Dev::PollsController < Dev::NightwatchController
  include Dev::ScenariosHelper

  def test_poll_scenario

    scenario =send(:"#{params[:scenario]}_scenario", {
                      poll_type: params[:poll_type],
                      anonymous: !!params[:anonymous],
                      hide_results: (params[:hide_results] || :off),
                      admin: !!params[:admin],
                      guest: !!params[:guest],
                      standalone: !!params[:standalone],
                      wip: !!params[:wip]
                    })

    sign_in(scenario[:observer]) if scenario[:observer].is_a?(User)

    if params[:email]
      @scenario = scenario
      last_email to: scenario[:observer]
    else
      redirect_to poll_url(scenario[:poll], Hash(scenario[:params]))
    end
  end

  def test_invite_to_poll
    admin = saved fake_user
    group = saved fake_group
    group.add_admin! admin

    if params[:guest]
      user = saved fake_unverified_user
    else
      user = saved fake_user
      group.add_member! user
    end

    discussion = fake_discussion(group: group)

    DiscussionService.create(discussion: discussion, actor: admin)

    # select poll type here
    poll = fake_poll(group: group, discussion: discussion, author: admin)
    PollService.create(poll: poll, actor: poll.author)

    PollService.invite(poll: poll, params: {recipient_emails: [user.email]}, actor: poll.author)
    last_email
  end

  def test_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = saved fake_discussion(group: group, author: group.admins.first)
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    redirect_to discussion_path(discussion)
  end

  def test_poll_in_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = saved fake_discussion(group: group, author: group.admins.first)
    DiscussionService.create(discussion: discussion, actor: discussion.author)
    poll = saved fake_poll(discussion: discussion)
    stance = saved fake_stance(poll: poll)
    StanceService.create(stance: stance, actor: group.members.last)
    redirect_to poll_url(poll)
  end

  def start_poll
    sign_in saved fake_user
    redirect_to new_poll_url
  end

  def test_activity_items
    user = fake_user
    group = saved fake_group
    group.add_admin! user
    discussion = saved fake_discussion(group: group)
    DiscussionService.create(discussion: discussion, actor: discussion.author)

    sign_in user
    create_activity_items(discussion: discussion, actor: user)
    redirect_to discussion_url(discussion)
  end

  private

  def create_activity_items(discussion: , actor: )
    # create poll
    options = {poll: %w[apple turnip peach],
               count: %w[yes no],
               proposal: %w[agree disagree abstain block],
               dot_vote: %w[birds bees trees]}

    AppConfig.poll_templates.keys.each do |poll_type|
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
end
