class Dev::PollsController < Dev::NightwatchController
  include Dev::PollsHelper
  include Dev::PollsScenarioHelper

  def test_poll_scenario

    scenario = send(:"#{params[:scenario]}_scenario", {
                      poll_type: params[:poll_type],
                      anonymous: !!params[:anonymous]
                    })

    sign_in(scenario[:observer]) if scenario[:observer].is_a?(User)

    if params[:email]
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

    PollService.announce(poll: poll, params: {user_ids: [user.id]}, actor: poll.author)
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
end
