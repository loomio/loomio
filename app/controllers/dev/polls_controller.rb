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

    scenario[:group].add_admin! scenario[:observer]

    sign_in(scenario[:observer]) if scenario[:observer].is_a?(User)

    case params[:format]
    when 'email'
      @scenario = scenario
      last_email to: scenario[:observer]
    when 'matrix'
      if scenario[:outcome]
        event = scenario[:outcome].events.last
      else
        event = scenario[:poll].events.last
      end
      poll = scenario[:poll]
      recipient = scenario[:observer]
      component = Views::Chatbot::Matrix::Poll.new(event: event, poll: poll, recipient: recipient)
      render component, layout: false
    when 'markdown'
      if scenario[:outcome]
        event = scenario[:outcome].events.last
      else
        event = scenario[:poll].events.last
      end
      poll = scenario[:poll]
      recipient = scenario[:observer]
      component = Views::Chatbot::Markdown::Poll.new(event: event, poll: poll, recipient: recipient)
      render component, layout: false, content_type: 'text/plain'
    when 'compare'
      if scenario[:outcome]
        event = scenario[:outcome].events.last
      else
        event = scenario[:poll].events.last
      end
      poll = scenario[:poll]
      recipient = scenario[:observer]

      event_key = EventMailer.event_key_for(event, recipient)
      subject_params = {
        title: poll.title,
        poll_type: I18n.t("decision_tools_card.#{poll.poll_type}_title"),
        actor: event.user.name,
        site_name: AppConfig.theme[:site_name]
      }
      email_subject = I18n.t("notifications.email_subject.#{event_key}", **subject_params)

      render Views::Dev::Polls::Compare.new(
        email_subject: email_subject,
        print: Views::Polls::Export.new(poll: poll, exporter: PollExporter.new(poll), recipient: recipient),
        email: EventMailer.build_component(event: event, recipient: recipient),
        matrix: Views::Chatbot::Matrix::Poll.new(event: event, poll: poll, recipient: recipient),
        markdown: Views::Chatbot::Markdown::Poll.new(event: event, poll: poll, recipient: recipient),
        slack: Views::Chatbot::Slack::Poll.new(event: event, poll: poll, recipient: recipient)
      ), layout: false
    when 'print'
      render Views::Polls::Export.new(
        poll: scenario[:poll],
        exporter: PollExporter.new(scenario[:poll]),
        recipient: scenario[:observer]
      )
    when 'csv'
      exporter = PollExporter.new(scenario[:poll])
      send_data exporter.to_csv, filename: exporter.file_name
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

    discussion = DiscussionService.create(params: {group_id: group.id, title: Faker::Quote.yoda.truncate(150), private: true}, actor: admin)

    # select poll type here
    poll = PollService.create(params: fake_poll_params(topic_id: discussion.topic_id), actor: admin)

    if params[:guest]
      PollService.invite(poll: poll, params: {recipient_emails: [user.email], notify_recipients: true}, actor: poll.author)
    end

    last_email
  end

  def test_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = DiscussionService.create(params: {group_id: group.id, title: Faker::Quote.yoda.truncate(150), private: true}, actor: group.admins.first)
    redirect_to discussion_url(discussion)
  end

  def test_poll_in_discussion
    group = create_group_with_members
    sign_in group.admins.first
    discussion = DiscussionService.create(params: {group_id: group.id, title: Faker::Quote.yoda.truncate(150), private: true}, actor: group.admins.first)
    poll = saved fake_poll(discussion: discussion)
    stance = saved fake_stance(poll: poll)
    StanceService.create(stance: stance, actor: group.members.last)
    redirect_to poll_url(poll)
  end

  def start_poll
    sign_in saved fake_user
    redirect_to new_poll_url
  end


  def test_scheduled_poll
    scenario = poll_scheduled_scenario(poll_type: params[:poll_type] || 'proposal')
    sign_in scenario[:observer]
    redirect_to poll_url(scenario[:poll])
  end

  def test_activity_items
    user = fake_user
    group = saved fake_group
    group.add_admin! user
    discussion = DiscussionService.create(params: {group_id: group.id, title: Faker::Quote.yoda.truncate(150), private: true}, actor: user)

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

    AppConfig.poll_types.keys.each do |poll_type|
      poll = PollService.create(
        params: {poll_type: poll_type, title: poll_type, details: 'fine print',
                 poll_option_names: options[poll_type.to_sym],
                 topic_id: discussion.topic_id},
        actor: actor)

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
      poll = PollService.create(
        params: {poll_type: poll_type, title: 'Which one?', details: 'fine print',
                 poll_option_names: options[poll_type.to_sym],
                 topic_id: discussion.topic_id},
        actor: actor)
      poll.update_attribute(:closing_at, 1.day.ago)

      # expire the poll
      PollService.expire_lapsed_polls
    end
  end
end
