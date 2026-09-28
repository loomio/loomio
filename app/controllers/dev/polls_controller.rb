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

  # Reuse the 50-member group, with a separate thread for each poll.
  def test_vote_table_matrix
    group = build_vote_table_matrix
    sign_in group.admins.first
    redirect_to group_path(group)
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

  def build_vote_table_matrix
    group = Group.find_by(name: 'Fifty-member voting group') || create_group_with_members.tap do |created|
      created.update!(name: 'Fifty-member voting group', vote_weights_allowed: true)
    end
    actor = group.admins.first
    voters = group.members.order(:id).limit(50).to_a
    (50 - voters.length).times do |index|
      voter = saved(fake_user(name: "Matrix voter #{format('%02d', index + 1)}"))
      group.add_member!(voter)
      voters << voter
    end
    group.update!(vote_weights_allowed: true) unless group.vote_weights_allowed?
    templates = PollTemplateService.default_templates.index_by(&:key)
    specs = [
      {template: 'check', label: 'sense check proposal', anonymous: false, votes: 20},
      {template: 'majority', anonymous: false, votes: 25},
      {template: 'majority', anonymous: true, votes: 10},
      {template: 'consent', anonymous: false, votes: 18},
      {template: 'consensus', anonymous: false, votes: 28},
      {template: 'poll', anonymous: false, votes: 40, options: %w[North South East West]},
      {template: 'poll', anonymous: true, votes: 12, options: %w[North South East West]},
      {template: 'poll', label: 'multiple choice poll', anonymous: false, votes: 35, options: %w[North South East West]},
      {template: 'dot_vote', anonymous: false, votes: 38, options: %w[Alpha Beta Gamma Delta]},
      {template: 'dot_vote', anonymous: true, votes: 15, options: %w[Alpha Beta Gamma Delta]},
      {template: 'score', anonymous: false, votes: 30, options: %w[Alpha Beta Gamma]},
      {template: 'score', anonymous: true, votes: 10, options: %w[Alpha Beta Gamma]},
      {template: 'ranked_choice', anonymous: false, votes: 18, options: %w[Alpha Beta Gamma Delta]},
      {template: 'ranked_choice', anonymous: true, votes: 35, options: %w[Alpha Beta Gamma Delta]},
      {template: 'meeting', anonymous: false, votes: 10, options: [3, 4, 5].map { |days| (Time.current + days.days).change(hour: 12).iso8601 }},
      {template: 'stv', anonymous: false, votes: 20, options: %w[Alex Blake Casey Drew]},
      {template: 'stv', anonymous: true, votes: 34, options: %w[Alex Blake Casey Drew]}
    ]

    specs.each do |spec|
      template = templates.fetch(spec[:template])
      title_prefix = "Votes table: #{spec[:label] || spec[:template]} #{spec[:anonymous] ? 'anonymous' : 'identified'}"
      title = "#{title_prefix} (#{spec[:votes]}/50 cast)"
      poll = group.polls.where(discarded_at: nil).where('polls.title LIKE ?', "#{title_prefix}%").first

      unless poll
        # Match PollTemplateModel#buildPoll, then override only the matrix's audience and ballot mode.
        poll_params = template.attributes.slice(*%w[
          poll_type details details_format chart_type min_score max_score minimum_stance_choices
          maximum_stance_choices dots_per_person limit_reason_length stance_reason_required
          notify_on_closing_soon notify_on_open reason_prompt process_name process_subtitle
          poll_option_name_format shuffle_options show_none_of_the_above hide_results quorum_pct
          tags default_duration_in_days
        ]).symbolize_keys.merge(
          group_id: group.id, private: true, title: title, poll_template_key: template.key,
          anonymous: spec[:anonymous], specified_voters_only: true,
          closing_at: template.default_duration_in_days.days.from_now,
          meeting_duration: template.meeting_duration,
          can_respond_maybe: template.can_respond_maybe
        )
        poll_params[:poll_options_attributes] = template.poll_options.each_with_index.map do |option, priority|
          option.slice('name', 'icon', 'meaning', 'prompt', 'test_operator', 'test_percent', 'test_against').merge(priority: priority)
        end if template.poll_options.any?
        poll_params[:poll_option_names] = spec[:options] if spec[:options]
        poll_params[:stv_seats] = 2 if template.poll_type == 'stv'
        poll_params[:maximum_stance_choices] = 3 if spec[:label] == 'multiple choice poll'
        poll = PollService.create(params: poll_params, actor: actor)
        raise "Could not create #{title}: #{poll.errors.full_messages.join(', ')}" unless poll.persisted?

        PollService.invite(
          poll: poll, actor: actor,
          params: {recipient_user_ids: voters.map(&:id), include_actor: true, notify_recipients: false}
        )
      end
      voters.first(spec[:votes]).each_with_index do |voter, index|
        choices = vote_table_matrix_choices(poll, index)
        if spec[:anonymous]
          next if poll.anonymous_poll_voters.find_by!(voter_id: voter.id).ballot_submitted?
          ballot = poll.anonymous_ballots.build(anonymous_ballot_choices_attributes: choices)
          AnonymousBallotService.create(anonymous_ballot: ballot, actor: voter)
        else
          stance = poll.stances.latest.find_by!(participant: voter)
          next if stance.cast_at.present?
          StanceService.update(
            stance: stance, actor: voter,
            params: {choice: choices.to_h { |choice| [poll.poll_options.find(choice[:poll_option_id]).name, choice[:score]] },
                     reason: 'A response for the votes table.'}
          )
        end
      end
      poll.update!(title: title) if poll.title != title
      PollService.close(poll: poll, actor: actor) if poll.hide_results == 'until_closed' && poll.closed_at.nil?
    end
    group
  end

  def vote_table_matrix_choices(poll, index)
    options = poll.poll_options.order(:priority).to_a
    random = Random.new(poll.id * 10_000 + index)
    case poll.poll_type
    when 'meeting'
      options.each_with_index.map do |option, i|
        {poll_option_id: option.id, score: random.rand < [0.8, 0.55, 0.3][i] ? 2 : random.rand(0..1)}
      end
    when 'dot_vote'
      picked = vote_table_matrix_pick(options, random, 2)
      picked.each_with_index.map { |option, i| {poll_option_id: option.id, score: i.zero? ? 5 : 3} }
    when 'score'
      options.each_with_index.map do |option, i|
        {poll_option_id: option.id, score: (4 - i + random.rand(-2..1)).clamp(0, 5)}
      end
    when 'ranked_choice'
      vote_table_matrix_pick(options, random, 3).each_with_index.map do |option, i|
        {poll_option_id: option.id, score: 3 - i}
      end
    when 'stv'
      vote_table_matrix_pick(options, random, 3).each_with_index.map do |option, i|
        {poll_option_id: option.id, score: i + 1}
      end
    else
      count = poll.maximum_stance_choices > 1 ? random.rand(2..3) : 1
      vote_table_matrix_pick(options, random, count).map { |option| {poll_option_id: option.id, score: 1} }
    end
  end

  def vote_table_matrix_pick(options, random, count)
    available = options.dup
    Array.new(count) do
      weighted = available.flat_map.with_index { |option, index| [option] * (available.length - index) }
      picked = weighted.sample(random: random)
      available.delete(picked)
      picked
    end
  end

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
