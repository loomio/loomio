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
        topic_item = scenario[:outcome].topic_items.last
      else
        topic_item = scenario[:poll].topic_items.last
      end
      poll = scenario[:poll]
      recipient = scenario[:observer]
      component = Views::Chatbot::Matrix::Poll.new(topic_item: topic_item, poll: poll, recipient: recipient)
      render component, layout: false
    when 'markdown'
      if scenario[:outcome]
        topic_item = scenario[:outcome].topic_items.last
      else
        topic_item = scenario[:poll].topic_items.last
      end
      poll = scenario[:poll]
      recipient = scenario[:observer]
      component = Views::Chatbot::Markdown::Poll.new(topic_item: topic_item, poll: poll, recipient: recipient)
      render component, layout: false, content_type: 'text/plain'
    when 'compare'
      if scenario[:outcome]
        topic_item = scenario[:outcome].topic_items.last
      else
        topic_item = scenario[:poll].topic_items.last
      end
      poll = scenario[:poll]
      recipient = scenario[:observer]

      event_key = NotificationMailer.event_key_for(topic_item, recipient)
      subject_params = {
        title: poll.title,
        poll_type: I18n.t("decision_tools_card.#{poll.poll_type}_title"),
        actor: topic_item.user.name,
        site_name: AppConfig.theme[:site_name]
      }
      email_subject = I18n.t("notifications.email_subject.#{event_key}", **subject_params)

      render Views::Dev::Polls::Compare.new(
        email_subject: email_subject,
        print: Views::Polls::Export.new(poll: poll, exporter: PollExporter.new(poll), recipient: recipient),
        email: NotificationMailer.build_component(topic_item: topic_item, recipient: recipient),
        matrix: Views::Chatbot::Matrix::Poll.new(topic_item: topic_item, poll: poll, recipient: recipient),
        markdown: Views::Chatbot::Markdown::Poll.new(topic_item: topic_item, poll: poll, recipient: recipient),
        slack: Views::Chatbot::Slack::Poll.new(topic_item: topic_item, poll: poll, recipient: recipient)
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
      user = saved fake_user(email: 'poll-member@example.com')
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
    admin = group.admins.first
    admin.update!(time_zone: params[:time_zone], autodetect_time_zone: false) if params[:time_zone]
    sign_in admin
    discussion = DiscussionService.create(params: {group_id: group.id, title: Faker::Quote.yoda.truncate(150), private: true}, actor: admin)
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
    group = create_group_with_members
    group.update!(vote_weights_allowed: true) if params[:weighted].present?
    sign_in group.admins.first
    redirect_to new_poll_url(group_id: group.id)
  end

  def edit_open_poll_vote_weights
    group = create_group_with_members
    group.update!(vote_weights_allowed: true)
    admin = group.admins.first
    poll = PollService.create(params: {
      title: 'Open weighted vote settings', poll_type: 'proposal', group_id: group.id,
      poll_option_names: %w[Agree Disagree], closing_at: 1.day.from_now,
      vote_weights_enabled: params[:weighted].present?
    }, actor: admin)
    sign_in admin
    redirect_to "/p/#{poll.key}/edit"
  end


  def test_scheduled_poll
    scenario = poll_scheduled_scenario(poll_type: params[:poll_type] || 'proposal', weighted: params[:weighted].present?)
    if params[:voter_count].present?
      voters = Array.new(params[:voter_count].to_i.clamp(0, 25)) { saved(fake_user) }
      voters.each { |voter| scenario[:group].add_member!(voter) }
      PollService.invite(
        poll: scenario[:poll],
        params: {recipient_user_ids: voters.map(&:id), notify_recipients: false},
        actor: scenario[:actor]
      )
    end
    sign_in scenario[:observer]
    redirect_to poll_url(scenario[:poll])
  end

  # Build a large weighted electorate with both cast and pending votes so the
  # voter modal, pagination, and result avatars can be inspected together.
  def test_many_weighted_voters
    scenario = poll_scheduled_scenario(poll_type: 'proposal', weighted: true)
    voter_count = params.fetch(:voter_count, 50).to_i.clamp(50, 100)
    group = scenario[:group]
    poll = scenario[:poll]
    actor = scenario[:actor]
    group.update!(name: 'Fifty-member voting group')

    voters = group.members.to_a
    (voter_count - voters.length).times do |index|
      voter = saved(fake_user(name: "Voter #{format('%02d', index + 1)}", email: "voter#{index + 1}@example.com"))
      group.add_member!(voter)
      voters << voter
    end

    weights = [0, 0.5, 1, 1.5, 2, 3, 5]
    group.memberships.active.order(:id).each_with_index do |membership, index|
      membership.update!(weight: weights[index % weights.length])
    end

    poll.update!(title: "Variable weights with #{voter_count} voters", opening_at: nil, opened_at: Time.current)
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: voters.map(&:id), include_actor: true, notify_recipients: false},
      actor: actor
    )
    StanceService.reset_weights(poll: poll, actor: actor, mode: 'membership')

    voters.reject { |voter| voter == actor }.first(12).each_with_index do |voter, index|
      stance = poll.stances.latest.find_by!(participant: voter)
      option = poll.poll_options[index % poll.poll_options.length]
      StanceService.update(stance: stance, actor: voter, params: {choice: {option.name => 1}})
    end

    sign_in actor
    redirect_to poll_url(poll)
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
               dot_vote: %w[birds bees trees],
               stv: %w[alice bob carol dave]}

    AppConfig.poll_types.keys.each do |poll_type|
      params = {poll_type: poll_type, title: poll_type, details: 'fine print',
                 poll_option_names: options[poll_type.to_sym],
                 topic_id: discussion.topic_id}
      if poll_type == 'stv'
        params[:stv_seats] = 2
        params[:stv_method] = 'scottish'
        params[:stv_quota] = 'droop'
      end
      poll = PollService.create(params: params, actor: actor)

      # edit the poll
      PollService.update(poll: poll, params: {title: 'choose!'}, actor: actor)

      # vote on the poll
      vote_choice = if %w[ranked_choice stv score dot_vote].include?(poll_type)
        poll.poll_option_names.each_with_index.to_h { |name, i| [name, i + 1] }
      else
        poll.poll_option_names.first
      end
      stance = Stance.new(poll: poll,
                          choice: vote_choice,
                          reason: 'democracy is in my shoes')
      StanceService.create(stance: stance, actor: actor)

      # close the poll
      PollService.close(poll: poll, actor: actor)

      # set an outcome
      outcome = Outcome.new(poll: poll, statement: 'We all voted')
      OutcomeService.create(outcome: outcome, actor: actor)

      # create poll
      params2 = {poll_type: poll_type, title: 'Which one?', details: 'fine print',
                 poll_option_names: options[poll_type.to_sym],
                 topic_id: discussion.topic_id}
      if poll_type == 'stv'
        params2[:stv_seats] = 2
        params2[:stv_method] = 'scottish'
        params2[:stv_quota] = 'droop'
      end
      poll = PollService.create(params: params2, actor: actor)
      poll.update_attribute(:closing_at, 1.day.ago)

      # expire the poll
      PollService.expire_lapsed_polls
    end
  end
end
