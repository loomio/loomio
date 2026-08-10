module Dev::Scenarios::OatmilkCooperative
  def setup_manual_oatmilk_group
    group, coordinator = create_manual_oatmilk_cooperative

    sign_in coordinator
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_discussion
    _group, coordinator, discussion = create_manual_oatmilk_cooperative

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_advice_discussion
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    production_lead = User.find_by!(email: 'alex@oatmilk.example')
    sales_lead = User.find_by!(email: 'samira@oatmilk.example')

    [
      [production_lead, 'The supplier can provide a trial washer next month. I will check its water use and cleaning cycle time.'],
      [sales_lead, 'Three cafes can join the trial if collections happen on Tuesdays. They also want a simple guide for customers.'],
      [coordinator, 'Please add the food-safety checks and staff training time to the comparison before we request quotes.'],
      [production_lead, 'I have added those requirements and will share the updated comparison after the warehouse visit.']
    ].each do |actor, body|
      CommentService.create(comment: Comment.new(parent: discussion, body: body), actor: actor)
    end

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_profile
    _group, coordinator, = create_manual_oatmilk_cooperative
    sign_in coordinator
    redirect_to '/profile'
  end

  def setup_manual_oatmilk_email_settings
    _group, coordinator, = create_manual_oatmilk_cooperative
    sign_in coordinator
    redirect_to '/email_preferences'
  end

  def setup_manual_oatmilk_bookmarks
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    comment = discussion.comments.first
    poll = discussion.polls.find_by!(title: 'Run a six-week returnable bottle trial')
    voter = User.find_by!(email: 'samira@oatmilk.example')
    stance = Stance.find_by!(poll: poll, participant: voter, latest: true)

    StanceService.update(
      stance: stance,
      actor: voter,
      params: {
        choice: {poll.poll_options.first.name => 1},
        reason: 'The six-week trial gives us enough time to measure returns and cleaning work.'
      }
    )
    PollService.close(poll: poll, actor: coordinator)
    outcome = Outcome.new(
      poll: poll,
      statement: 'We will run the bottle trial with three cafes and review the results after six weeks.'
    )
    OutcomeService.create(outcome: outcome, actor: coordinator)

    [discussion, comment, poll, stance, outcome].each do |bookmarkable|
      Bookmark.create!(user: coordinator, bookmarkable: bookmarkable)
    end

    sign_in coordinator
    redirect_to '/bookmarks'
  end

  def setup_manual_oatmilk_thread_navigation
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    commenter = User.find_by!(email: 'alex@oatmilk.example')
    12.times do |index|
      CommentService.create(
        comment: Comment.new(
          parent: discussion,
          body: "Bottle trial update #{index + 1}: record the collection and washing observations for the weekly review."
        ),
        actor: commenter
      )
    end
    reader = TopicReader.for(user: coordinator, topic: discussion.topic)
    reader.read_ranges = [[0, 1]]
    reader.last_read_at = 1.hour.ago
    reader.save!

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_signed_out
    create_manual_oatmilk_cooperative
    sign_out
    redirect_to dashboard_path
  end

  def setup_manual_oatmilk_login_token
    _group, coordinator, = create_manual_oatmilk_cooperative
    login_token = LoginToken.create!(user: coordinator)
    sign_out
    redirect_to login_token_path(login_token.token)
  end

  def setup_manual_oatmilk_chatbot
    group, coordinator, = create_manual_oatmilk_cooperative
    chatbot = Chatbot.new(
      group: group,
      author: coordinator,
      kind: 'webhook',
      webhook_kind: 'slack',
      name: 'Oatmilk Cooperative chat',
      server: 'https://hooks.example.com/services/oatmilk/cooperative/docs',
      event_kinds: [],
      notification_only: false
    )
    chatbot.save!(validate: false)
    sign_in coordinator

    if params[:view] == 'poll'
      poll = group.polls.find_by!(title: 'Run a six-week returnable bottle trial')
      redirect_to poll_path(poll)
    else
      redirect_to group_path(group)
    end
  end

  def setup_manual_oatmilk_translated_comment
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    comment = discussion.comments.first
    comment.update_columns(
      body: 'Puedo pedir a tres cafeterias que registren cuantas botellas se devuelven cada semana.',
      content_locale: 'es'
    )
    Translation.create!(
      translatable: comment,
      language: 'en',
      fields: {'body' => 'I can ask three cafes to track how many bottles are returned each week.'}
    )

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_formatting
    group, coordinator, = create_manual_oatmilk_cooperative
    params.fetch(:key, 0).to_i.times do |index|
      DiscussionService.create(
        params: {
          group_id: group.id,
          title: "Formatting draft #{index + 1}",
          description: 'A placeholder used to keep screenshot editor drafts isolated.'
        },
        actor: coordinator
      )
    end
    discussion = DiscussionService.create(
      params: {
        group_id: group.id,
        title: 'Returnable bottles for cafe customers',
        description: 'Use formatting to make the returnable bottle trial easy to scan.',
        allow_reactions: true
      },
      actor: coordinator
    )

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_direct_discussions
    _group, coordinator, = create_manual_oatmilk_cooperative
    participants = User.where(email: ['samira@oatmilk.example', 'alex@oatmilk.example'])
    DiscussionService.create(
      params: {
        title: 'Cafe bottle collection check-in',
        description: 'Coordinate collection dates directly with the people managing the returnable bottle trial.',
        recipient_user_ids: participants.pluck(:id)
      },
      actor: coordinator
    )

    sign_in coordinator
    redirect_to '/dashboard/direct_discussions'
  end

  def setup_manual_oatmilk_join_group
    group, = create_manual_oatmilk_cooperative
    visitor = create_manual_oatmilk_member(
      name: 'Riley Thompson',
      email: 'riley@oatmilk.example'
    )

    sign_in visitor
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_invitations
    group, coordinator, = create_manual_oatmilk_invitations

    sign_in coordinator
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_subgroup_invitations
    _group, coordinator, subgroups = create_manual_oatmilk_invitations

    sign_in coordinator
    redirect_to group_path(subgroups.first)
  end

  def setup_manual_oatmilk_closed_subgroup
    _group, coordinator, subgroup, = create_manual_oatmilk_closed_subgroup

    sign_in coordinator
    redirect_to group_path(subgroup)
  end

  def setup_manual_oatmilk_closed_subgroup_admin
    _group, _coordinator, subgroup, subgroup_creator = create_manual_oatmilk_closed_subgroup

    sign_in subgroup_creator
    redirect_to group_path(subgroup)
  end

  def setup_manual_oatmilk_closed_subgroup_member
    _group, coordinator, subgroup, = create_manual_oatmilk_closed_subgroup
    subgroup.add_member!(coordinator)

    sign_in coordinator
    redirect_to group_path(subgroup)
  end

  def setup_manual_oatmilk_delegates
    group, coordinator = create_manual_oatmilk_cooperative
    mark_manual_oatmilk_delegates(group)

    sign_in coordinator
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_delegate_poll
    group, coordinator = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    mark_manual_oatmilk_delegates(group)

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_unreleased_email
    group, coordinator = create_manual_oatmilk_cooperative
    ReceivedEmail.create!(
      group: group,
      headers: {
        to: "#{group.handle}@#{ENV.fetch('REPLY_HOSTNAME', 'localhost')}",
        from: 'Taylor Brooks <taylor@bottles.example>',
        subject: 'Returnable bottle collection proposal'
      },
      body_html: '<p>Could we arrange a collection schedule for returned bottles?</p>',
      body_text: 'Could we arrange a collection schedule for returned bottles?'
    )

    sign_in coordinator
    redirect_to group_emails_path(group)
  end

  def setup_manual_oatmilk_participation_report
    group, coordinator = create_manual_oatmilk_cooperative
    group.update_column(:created_at, 3.months.ago)
    Topic.where(group_id: group.id).order(:id).each_with_index do |topic, index|
      topic.update_column(:created_at, (2 - index).months.ago)
    end
    group.discussions.first.comments.update_all(created_at: 1.month.ago)

    sign_in coordinator
    redirect_to "/report/?group_ids=#{group.id}&start_on=#{3.months.ago.strftime('%Y-%m')}"
  end

  def setup_manual_oatmilk_new_discussion
    group, coordinator = create_manual_oatmilk_cooperative
    group.tags.create!(name: 'Sustainability', color: '#2e7d32')
    group.tags.create!(name: 'Packaging', color: '#1565c0')

    sign_in coordinator
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_tags
    group, coordinator, discussion = create_manual_oatmilk_cooperative
    group.tags.create!(name: 'Cafe partnerships', color: '#6a1b9a')
    group.tags.create!(name: 'Packaging', color: '#1565c0')
    group.tags.create!(name: 'Sustainability', color: '#2e7d32')
    discussion.topic.update!(tags: ['Cafe partnerships', 'Packaging'])
    group.discussions.find_by!(title: 'Weekly production schedule').topic.update!(tags: ['Sustainability'])

    sign_in coordinator
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_tasks
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    add_manual_oatmilk_tasks(discussion, coordinator)

    sign_in coordinator
    redirect_to '/tasks'
  end

  def setup_manual_oatmilk_task_discussion
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    add_manual_oatmilk_tasks(discussion, coordinator)

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_example
    group, coordinator, = create_manual_oatmilk_cooperative
    production_lead = User.find_by!(email: 'samira@oatmilk.example')
    sales_lead = User.find_by!(email: 'alex@oatmilk.example')
    kind = params.require(:kind)

    example = manual_oatmilk_example(kind)
    discussion = DiscussionService.create(
      params: {
        group_id: group.id,
        title: example.fetch(:title),
        description: example.fetch(:description),
        description_format: 'html',
        private: false,
        allow_reactions: true
      },
      actor: coordinator
    )

    Array(example[:comments]).zip([production_lead, sales_lead]).each do |body, actor|
      CommentService.create(comment: Comment.new(parent: discussion, body: body), actor: actor)
    end

    if example[:poll]
      poll_data = example.fetch(:poll)
      poll = PollService.create(
        params: {
          topic_id: discussion.topic_id,
          title: poll_data.fetch(:title),
          details: poll_data.fetch(:details),
          poll_type: poll_data.fetch(:type),
          poll_option_names: poll_data.fetch(:options),
          closing_at: 1.week.from_now
        },
        actor: coordinator
      )

      if example[:outcome]
        PollService.close(poll: poll, actor: coordinator)
        OutcomeService.create(
          outcome: Outcome.new(poll: poll, statement: example.fetch(:outcome)),
          actor: coordinator
        )
      end
    end

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  def setup_manual_oatmilk_outcome
    _group, coordinator, discussion = create_manual_oatmilk_cooperative
    poll = discussion.polls.find_by!(title: 'Run a six-week returnable bottle trial')
    PollService.close(poll: poll, actor: coordinator)

    if params[:published] == '1'
      OutcomeService.create(
        outcome: Outcome.new(
          poll: poll,
          review_on: 6.months.from_now.to_date,
          statement: 'The cooperative approved the six-week returnable bottle trial. Jamie will confirm the cafe collection schedule, and we will review return rates and washing time when the trial ends.'
        ),
        actor: coordinator
      )
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_invite_poll
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    production_lead = User.find_by!(email: 'samira@oatmilk.example')
    sales_lead = User.find_by!(email: 'alex@oatmilk.example')

    subgroup = Group.new(
      name: 'Bottle Trial Board',
      description: 'Oversee the returnable bottle trial and report back to the cooperative.',
      parent: group,
      group_privacy: 'closed',
      creator: coordinator
    )
    GroupService.create(group: subgroup, actor: coordinator)
    subgroup.add_member!(production_lead)
    subgroup.add_member!(sales_lead)

    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Approve the bottle trial responsibilities',
        details: 'Confirm the collection, washing, and reporting responsibilities before the six-week trial begins.',
        poll_type: 'proposal',
        poll_option_names: %w[agree abstain disagree block],
        specified_voters_only: true,
        closing_at: 1.week.from_now
      },
      actor: coordinator
    )

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_quorum
    group, coordinator, discussion = create_manual_oatmilk_cooperative
    production_lead = User.find_by!(email: 'samira@oatmilk.example')
    sales_lead = User.find_by!(email: 'alex@oatmilk.example')
    operations_lead = create_manual_oatmilk_member(
      name: 'Taylor Reed',
      email: 'taylor@oatmilk.example'
    )
    finance_lead = create_manual_oatmilk_member(
      name: 'Morgan Price',
      email: 'morgan@oatmilk.example'
    )
    group.add_member!(operations_lead)
    group.add_member!(finance_lead)

    poll = discussion.polls.find_by!(title: 'Run a six-week returnable bottle trial')
    poll.update!(quorum_pct: 60)

    vote_share = params[:vote_share] == '1'
    if vote_share
      poll.poll_options.find_by!(icon: 'agree').update!(
        test_operator: 'gte',
        test_percent: 75,
        test_against: 'voter_percent'
      )
    end

    votes = params.fetch(:votes, 0).to_i.clamp(0, vote_share ? 5 : 3)
    vote_plan = if vote_share
      [
        [coordinator, 'agree', 'The trial budget is practical and includes the expected washing costs.'],
        [production_lead, 'agree', 'The production plan includes enough time for washing checks.'],
        [sales_lead, 'agree', 'The cafe partners have confirmed the deposit amount.'],
        [operations_lead, 'disagree', 'We should allow more for replacement bottles.'],
        [finance_lead, 'agree', 'The collection budget is within the trial allocation.']
      ]
    else
      [
        [coordinator, 'agree', 'The trial budget is practical and includes the expected washing costs.'],
        [production_lead, 'disagree', 'We should allow more for replacement bottles.'],
        [sales_lead, 'agree', 'The cafe partners have confirmed the deposit amount.']
      ]
    end
    vote_plan.first(votes).each do |voter, option, reason|
      stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
      poll_option = poll.poll_options.find_by!(icon: option)
      StanceService.update(
        stance: stance,
        actor: voter,
        params: {
          choice: {poll_option.name => 1},
          reason: reason
        }
      )
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_stv
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    voters = [
      coordinator,
      User.find_by!(email: 'samira@oatmilk.example'),
      User.find_by!(email: 'alex@oatmilk.example')
    ]
    [
      ['Taylor Reed', 'taylor@oatmilk.example'],
      ['Morgan Price', 'morgan@oatmilk.example'],
      ['Riley Thompson', 'riley@oatmilk.example'],
      ['Casey Nguyen', 'casey@oatmilk.example'],
      ['Jordan Williams', 'jordan@oatmilk.example'],
      ['Avery Brown', 'avery@oatmilk.example'],
      ['Robin Singh', 'robin@oatmilk.example']
    ].each do |name, email|
      member = create_manual_oatmilk_member(name: name, email: email)
      group.add_member!(member)
      voters << member
    end

    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Elect the reusable packaging committee',
        details: 'Rank the candidates who should oversee bottle deposits, collection, washing, and the review of the six-week trial.',
        poll_type: 'stv',
        poll_option_names: ['Samira Patel', 'Alex Morgan', 'Taylor Reed', 'Morgan Price', 'Riley Thompson'],
        stv_seats: 3,
        stv_method: 'scottish',
        stv_quota: 'droop',
        closing_at: 1.week.from_now
      },
      actor: coordinator
    )
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: voters.map(&:id)},
      actor: coordinator
    )

    if params[:results] == '1'
      ballots = [
        ['Samira Patel', 'Alex Morgan', 'Morgan Price', 'Taylor Reed', 'Riley Thompson'],
        ['Samira Patel', 'Alex Morgan', 'Morgan Price', 'Riley Thompson', 'Taylor Reed'],
        ['Samira Patel', 'Alex Morgan', 'Morgan Price', 'Taylor Reed', 'Riley Thompson'],
        ['Samira Patel', 'Morgan Price', 'Alex Morgan', 'Riley Thompson', 'Taylor Reed'],
        ['Samira Patel', 'Morgan Price', 'Alex Morgan', 'Taylor Reed', 'Riley Thompson'],
        ['Alex Morgan', 'Morgan Price', 'Samira Patel', 'Riley Thompson', 'Taylor Reed'],
        ['Alex Morgan', 'Morgan Price', 'Riley Thompson', 'Samira Patel', 'Taylor Reed'],
        ['Morgan Price', 'Alex Morgan', 'Samira Patel', 'Riley Thompson', 'Taylor Reed'],
        ['Taylor Reed', 'Morgan Price', 'Alex Morgan', 'Samira Patel', 'Riley Thompson'],
        ['Riley Thompson', 'Morgan Price', 'Alex Morgan', 'Samira Patel', 'Taylor Reed']
      ]
      voters.zip(ballots).each do |voter, ranking|
        stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
        StanceService.update(
          stance: stance,
          actor: voter,
          params: {
            choice: ranking.each_with_index.to_h { |name, index| [name, index + 1] },
            reason: 'I ranked the candidates according to the skills needed for the bottle trial.'
          }
        )
      end
      PollService.close(poll: poll, actor: coordinator)
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_new_poll
    group, coordinator, = create_manual_oatmilk_cooperative

    sign_in coordinator
    redirect_to "/p/new?template_key=#{params.require(:poll_type)}&group_id=#{group.id}"
  end

  def setup_manual_oatmilk_meeting_poll
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    voters = [
      coordinator,
      User.find_by!(email: 'samira@oatmilk.example'),
      User.find_by!(email: 'alex@oatmilk.example')
    ]
    [['Taylor Reed', 'taylor@oatmilk.example'], ['Morgan Price', 'morgan@oatmilk.example']].each do |name, email|
      member = create_manual_oatmilk_member(name: name, email: email)
      group.add_member!(member)
      voters << member
    end

    meeting_day = 1.week.from_now.beginning_of_day
    times = [
      meeting_day + 10.hours,
      meeting_day + 14.hours,
      meeting_day + 1.day + 10.hours,
      meeting_day + 2.days + 14.hours
    ]
    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Schedule the bottle trial planning meeting',
        details: 'Choose the times you can meet to confirm cafe collections, washing checks, and responsibilities for the six-week trial.',
        poll_type: 'meeting',
        poll_option_names: times.map(&:iso8601),
        meeting_duration: 90,
        closing_at: 4.days.from_now
      },
      actor: coordinator
    )
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: voters.map(&:id)},
      actor: coordinator
    )

    scores = [
      [2, 2, 1, 0],
      [2, 1, 2, 0],
      [1, 2, 2, 0],
      [0, 2, 1, 2],
      [0, 1, 2, 2]
    ]
    votes = params[:mode] == 'vote' ? 4 : 5
    voters.last(votes).zip(scores.last(votes)).each do |voter, values|
      stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
      StanceService.update(
        stance: stance,
        actor: voter,
        params: {
          choice: poll.poll_options.zip(values).to_h { |option, score| [option.name, score] },
          reason: 'I can rearrange other work if the most popular time is selected.'
        }
      )
    end
    PollService.close(poll: poll, actor: coordinator) if params[:mode] == 'closed'

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_opt_in
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    volunteers = [
      coordinator,
      User.find_by!(email: 'samira@oatmilk.example'),
      User.find_by!(email: 'alex@oatmilk.example')
    ]
    [['Taylor Reed', 'taylor@oatmilk.example'], ['Morgan Price', 'morgan@oatmilk.example']].each do |name, email|
      member = create_manual_oatmilk_member(name: name, email: email)
      group.add_member!(member)
      volunteers << member
    end

    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Join the reusable packaging working group',
        details: 'We need three people to coordinate bottle deposits, cafe collections, washing checks, and the review of the six-week trial.',
        poll_type: 'count',
        poll_option_names: %w[accept decline],
        agree_target: 3,
        closing_at: 1.week.from_now
      },
      actor: coordinator
    )
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: volunteers.map(&:id)},
      actor: coordinator
    )
    [[coordinator, 'accept'], [volunteers[1], 'accept'], [volunteers[2], 'decline']].each do |voter, icon|
      stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
      option = poll.poll_options.find_by!(icon: icon == 'accept' ? 'agree' : 'disagree')
      StanceService.update(
        stance: stance,
        actor: voter,
        params: {choice: {option.name => 1}, reason: icon == 'accept' ? 'I can help coordinate the trial.' : 'I cannot commit enough time this month.'}
      )
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_poll_type
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    voters = [
      coordinator,
      User.find_by!(email: 'samira@oatmilk.example'),
      User.find_by!(email: 'alex@oatmilk.example')
    ]
    [['Taylor Reed', 'taylor@oatmilk.example'], ['Morgan Price', 'morgan@oatmilk.example']].each do |name, email|
      member = create_manual_oatmilk_member(name: name, email: email)
      group.add_member!(member)
      voters << member
    end

    poll_type = params.require(:poll_type)
    config = manual_oatmilk_poll_type_config.fetch(poll_type)
    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: config.fetch(:title),
        details: config.fetch(:details),
        poll_type: poll_type,
        poll_option_names: config.fetch(:options),
        minimum_stance_choices: config[:minimum_stance_choices],
        maximum_stance_choices: config[:maximum_stance_choices],
        dots_per_person: config[:dots_per_person],
        min_score: config[:min_score],
        max_score: config[:max_score],
        closing_at: 1.week.from_now
      }.compact,
      actor: coordinator
    )
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: voters.map(&:id)},
      actor: coordinator
    )

    if params[:mode].in?(%w[results closed outcome])
      config.fetch(:votes).zip(voters).each do |choice, voter|
        stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
        StanceService.update(
          stance: stance,
          actor: voter,
          params: {choice: choice, reason: config.fetch(:reason)}
        )
      end
    end

    if params[:mode].in?(%w[closed outcome])
      PollService.close(poll: poll, actor: coordinator)
    end

    if params[:mode] == 'outcome'
      OutcomeService.create(
        outcome: Outcome.new(
          poll: poll,
          statement: 'We will give cafe collections and the washing workflow equal time at the planning meeting, then publish the agreed trial schedule.'
        ),
        actor: coordinator
      )
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_poll_template_form
    group, coordinator, = create_manual_oatmilk_cooperative
    sign_in coordinator
    query = "group_id=#{group.id}"
    query += "&template_key=#{params[:template_key]}" if params[:template_key].present?
    redirect_to "/poll_templates/new?#{query}"
  end

  def setup_manual_oatmilk_custom_poll_template
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    template = create_manual_oatmilk_poll_template(group: group, coordinator: coordinator)
    template.discard! if params[:hidden].present?
    sign_in coordinator

    if params[:view] == 'edit'
      redirect_to "/poll_templates/#{template.id}/edit"
    else
      redirect_to discussion_path(discussion)
    end
  end

  def setup_manual_oatmilk_advice_template
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    template = create_manual_oatmilk_advice_template(group: group, coordinator: coordinator)
    sign_in coordinator
    if params[:view] == 'form'
      redirect_to "/p/new?template_key=#{template.id}&group_id=#{group.id}"
    else
      redirect_to discussion_path(discussion)
    end
  end

  def setup_manual_oatmilk_advice_poll
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    voters = [
      coordinator,
      User.find_by!(email: 'samira@oatmilk.example'),
      User.find_by!(email: 'alex@oatmilk.example')
    ]
    template = create_manual_oatmilk_advice_template(group: group, coordinator: coordinator)
    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Choose a bottle washing supplier',
        details: 'We need advice about capacity, food-safety records, water use, and support before selecting a supplier for the returnable bottle trial.',
        poll_type: template.poll_type,
        poll_template_id: template.id,
        minimum_stance_choices: template.minimum_stance_choices,
        maximum_stance_choices: template.maximum_stance_choices,
        dots_per_person: template.dots_per_person,
        poll_options_attributes: template.poll_options.map do |option|
          option.slice('name', 'icon', 'meaning', 'prompt')
        end,
        closing_at: 1.week.from_now
      },
      actor: coordinator
    )
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: voters.map(&:id)},
      actor: coordinator
    )

    if params[:mode] == 'results'
      [[voters[1], 'Agree'], [voters[2], 'Agree']].each do |voter, option_name|
        stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
        StanceService.update(
          stance: stance,
          actor: voter,
          params: {
            choice: {option_name => 1},
            reason: 'Confirm service response times and batch-record support before signing the supplier agreement.'
          }
        )
      end
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  def setup_manual_oatmilk_proposal_template_poll
    group, coordinator, = create_manual_oatmilk_cooperative
    discussion = group.discussions.find_by!(title: 'Weekly production schedule')
    voters = [
      coordinator,
      User.find_by!(email: 'samira@oatmilk.example'),
      User.find_by!(email: 'alex@oatmilk.example')
    ]
    template_key = params.require(:template)
    template = (PollTemplateService.default_templates + PollTemplateService.example_templates)
      .find { |item| item.key == template_key }
    raise ActiveRecord::RecordNotFound, "Unknown poll template #{template_key}" unless template

    poll_params = {
      topic_id: discussion.topic_id,
      title: manual_oatmilk_proposal_title(template_key),
      details: manual_oatmilk_proposal_details(template_key),
      poll_type: template.poll_type,
      poll_template_key: template.key,
      minimum_stance_choices: template.minimum_stance_choices,
      maximum_stance_choices: template.maximum_stance_choices,
      dots_per_person: template.dots_per_person,
      stance_reason_required: template.stance_reason_required,
      closing_at: 1.week.from_now
    }
    if template.poll_options.any?
      poll_params[:poll_options_attributes] = template.poll_options.map do |option|
        option.slice('name', 'icon', 'meaning', 'prompt')
      end
    end
    poll = PollService.create(params: poll_params, actor: coordinator)
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: voters.map(&:id)},
      actor: coordinator
    )

    if params[:mode].in?(%w[results outcome]) && poll.poll_options.any?
      voters.each_with_index do |voter, index|
        stance = Stance.find_by!(poll: poll, participant: voter, latest: true)
        option = poll.poll_options[index % [poll.poll_options.length, 3].min]
        StanceService.update(
          stance: stance,
          actor: voter,
          params: {
            choice: {option.name => 1},
            reason: manual_oatmilk_proposal_reason(template_key, index)
          }
        )
      end
    end

    if params[:mode] == 'outcome'
      PollService.close(poll: poll, actor: coordinator)
      OutcomeService.create(
        outcome: Outcome.new(
          poll: poll,
          statement: "The cooperative will proceed with the returnable bottle trial and review collection and washing data after six weeks."
        ),
        actor: coordinator
      )
    end

    sign_in coordinator
    redirect_to poll_path(poll)
  end

  private

  def manual_oatmilk_proposal_title(template_key)
    {
      'advice' => 'Choose a bottle washing supplier',
      'consent' => 'Start the returnable bottle trial next month',
      'consensus' => 'Adopt the cooperative bottle return standard',
      'check' => 'Is the bottle trial plan ready for final review?',
      'majority' => 'Approve the returnable bottle trial budget',
      'gradients_of_agreement' => 'Support the proposed cafe collection schedule',
      'question' => 'Questions about the returnable bottle trial'
    }.fetch(template_key)
  end

  def manual_oatmilk_proposal_details(_template_key)
    "Review the collection schedule, deposit guidance, washing workflow, food-safety checks, and return-rate reporting before responding."
  end

  def manual_oatmilk_proposal_reason(_template_key, index)
    [
      'The collection schedule and washing checks are ready.',
      'Confirm supplier response times before launch.',
      'Add a weekly return-rate review during the trial.'
    ][index]
  end

  def create_manual_oatmilk_advice_template(group:, coordinator:)
    source = PollTemplateService.example_templates.find { |item| item.key == 'advice' }
    PollTemplate.create!(
      group: group,
      author: coordinator,
      poll_type: source.poll_type,
      process_name: source.process_name,
      process_subtitle: source.process_subtitle,
      process_introduction: source.process_introduction,
      title: source.title,
      title_placeholder: source.title_placeholder,
      details: source.details,
      reason_prompt: source.reason_prompt,
      outcome_statement: source.outcome_statement,
      default_duration_in_days: source.default_duration_in_days,
      minimum_stance_choices: source.minimum_stance_choices,
      maximum_stance_choices: source.maximum_stance_choices,
      dots_per_person: source.dots_per_person,
      stance_reason_required: source.stance_reason_required,
      poll_options: source.poll_options,
      tags: source.tags
    )
  end

  def create_manual_oatmilk_poll_template(group:, coordinator:)
    PollTemplate.create!(
      group: group,
      author: coordinator,
      poll_type: 'proposal',
      process_name: 'Bottle trial readiness review',
      process_subtitle: 'Check whether the returnable bottle trial is ready to start',
      process_introduction: '<p>Use this review before starting a bottle trial. Invite advice from people responsible for cafe collections, washing, food safety, and reporting.</p>',
      title: 'Is the returnable bottle trial ready to start?',
      details: '<p>Review the collection schedule, deposit guidance, washing workflow, food-safety checks, and return-rate reporting.</p>',
      reason_prompt: 'What is ready, and what needs attention before the trial starts?',
      outcome_statement: 'Record whether the trial will start and any work that must be completed first.',
      default_duration_in_days: 5,
      poll_options: [
        {name: 'Ready', icon: 'agree', color: '#70C9F8', meaning: 'The trial can start as planned.', prompt: 'What gives you confidence the trial is ready?'},
        {name: 'Needs work', icon: 'abstain', color: '#C8E56E', meaning: 'Some work should be completed before launch.', prompt: 'What needs attention before the trial starts?'},
        {name: 'Not ready', icon: 'disagree', color: '#D38FE1', meaning: 'A significant issue prevents the trial from starting.', prompt: 'What issue must be resolved?'}
      ]
    )
  end

  def manual_oatmilk_poll_type_config
    {
      'poll' => {
        title: 'Which bottle trial topics need the most meeting time?',
        details: 'Choose up to two topics for the Oatmilk Cooperative planning meeting. We will use the result to set the agenda.',
        options: ['Cafe collection schedule', 'Bottle deposit amount', 'Washing workflow', 'Return-rate reporting'],
        minimum_stance_choices: 1,
        maximum_stance_choices: 2,
        votes: [
          {'Cafe collection schedule' => 1, 'Washing workflow' => 1},
          {'Cafe collection schedule' => 1, 'Bottle deposit amount' => 1},
          {'Washing workflow' => 1, 'Return-rate reporting' => 1},
          {'Cafe collection schedule' => 1, 'Return-rate reporting' => 1}
        ],
        reason: 'These topics affect every cafe collection, so we should confirm them together before the trial starts.'
      },
      'score' => {
        title: 'Assess our readiness for the returnable bottle trial',
        details: 'Score each part of the proposed trial from 0 (not ready) to 10 (ready).',
        options: ['Cafe collection plan', 'Washing capacity', 'Food-safety process', 'Return-rate reporting'],
        min_score: 0,
        max_score: 10,
        votes: [
          {'Cafe collection plan' => 8, 'Washing capacity' => 6, 'Food-safety process' => 7, 'Return-rate reporting' => 5},
          {'Cafe collection plan' => 7, 'Washing capacity' => 8, 'Food-safety process' => 6, 'Return-rate reporting' => 6},
          {'Cafe collection plan' => 9, 'Washing capacity' => 7, 'Food-safety process' => 8, 'Return-rate reporting' => 4},
          {'Cafe collection plan' => 6, 'Washing capacity' => 7, 'Food-safety process' => 7, 'Return-rate reporting' => 6}
        ],
        reason: 'This score reflects the work completed and the checks still needed before launch.'
      },
      'dot_vote' => {
        title: 'Prioritise work for the returnable bottle trial',
        details: 'Allocate eight points across the work that needs attention before the six-week trial starts.',
        options: ['Cafe collection schedule', 'Bottle deposit guidance', 'Washing workflow', 'Food-safety checks', 'Return-rate reporting'],
        dots_per_person: 8,
        votes: [
          {'Cafe collection schedule' => 3, 'Washing workflow' => 3, 'Food-safety checks' => 2},
          {'Cafe collection schedule' => 2, 'Bottle deposit guidance' => 2, 'Return-rate reporting' => 4},
          {'Washing workflow' => 4, 'Food-safety checks' => 3, 'Return-rate reporting' => 1},
          {'Cafe collection schedule' => 2, 'Bottle deposit guidance' => 1, 'Washing workflow' => 2, 'Food-safety checks' => 3}
        ],
        reason: 'I have allocated points to the work that carries the most operational risk.'
      },
      'ranked_choice' => {
        title: 'Rank the bottle trial priorities',
        details: 'Rank the four priorities in the order the cooperative should address them.',
        options: ['Food-safety checks', 'Washing workflow', 'Cafe collection schedule', 'Return-rate reporting'],
        minimum_stance_choices: 4,
        votes: [
          {'Food-safety checks' => 1, 'Washing workflow' => 2, 'Cafe collection schedule' => 3, 'Return-rate reporting' => 4},
          {'Washing workflow' => 1, 'Food-safety checks' => 2, 'Return-rate reporting' => 3, 'Cafe collection schedule' => 4},
          {'Cafe collection schedule' => 1, 'Washing workflow' => 2, 'Food-safety checks' => 3, 'Return-rate reporting' => 4},
          {'Food-safety checks' => 1, 'Cafe collection schedule' => 2, 'Washing workflow' => 3, 'Return-rate reporting' => 4}
        ],
        reason: 'I ranked the work by safety impact and the dependencies between each step.'
      }
    }
  end

  def add_manual_oatmilk_tasks(discussion, coordinator)
    due_on = 2.weeks.from_now.to_date.iso8601
    discussion.update!(
      description_format: 'html',
      description: <<~HTML
        <p>Tasks for preparing the returnable bottle trial:</p>
        <ul data-type="taskList">
          <li data-uid="81001" data-type="taskItem" data-checked="false" data-author-id="#{coordinator.id}" data-due-on="#{due_on}" data-remind="1">
            <p>Confirm bottle washer capacity with suppliers <span class="mention" data-mention-id="#{coordinator.username}">@#{coordinator.name}</span></p>
          </li>
          <li data-uid="81002" data-type="taskItem" data-checked="true" data-author-id="#{coordinator.id}">
            <p>Share cafe collection dates <span class="mention" data-mention-id="#{coordinator.username}">@#{coordinator.name}</span></p>
          </li>
        </ul>
      HTML
    )
  end

  def manual_oatmilk_example(kind)
    examples = {
      'meeting_focus' => {
        title: 'Plan our September production meeting',
        description: '<p>What should we focus on at our September production meeting?</p><p>Add agenda items that need the whole cooperative’s attention.</p>',
        comments: [
          'Please include bottle-return rates from the three cafe partners.',
          'I would like ten minutes to compare delivery schedules for the trial.'
        ]
      },
      'meeting_agenda' => {
        title: 'September production meeting agenda',
        description: '<p><strong>Meeting focus:</strong> preparing the six-week returnable bottle trial.</p><ul><li>Cafe collection schedule</li><li>Washing capacity and food-safety checks</li><li>Transport costs and responsibilities</li></ul>',
        poll: {
          title: 'I have read the agenda and will attend',
          details: 'Confirm that you have reviewed the agenda before the meeting.',
          type: 'count',
          options: %w[accept decline]
        }
      },
      'meeting_minutes' => {
        title: 'September meeting minutes and actions',
        description: '<p>Thanks for a focused meeting. The minutes record the collection timetable, washing trial, and assigned follow-up tasks.</p>',
        poll: {
          title: 'Approve the September meeting minutes',
          details: 'Confirm that the minutes accurately record our decisions and actions.',
          type: 'proposal',
          options: %w[agree abstain disagree block]
        }
      },
      'document_introduce' => {
        title: 'Develop a reusable packaging policy',
        description: '<p>We need a shared policy for bottle deposits, collection, washing, and replacement. Add requirements or risks that the first draft should cover.</p>',
        comments: [
          'The policy should explain who records damaged or missing bottles.',
          'Cafe partners need a simple collection checklist and a named contact.'
        ]
      },
      'document_integrate' => {
        title: 'Reusable packaging policy — first draft',
        description: '<p>The first draft includes the feedback about deposits, damaged bottles, collection records, and cafe support.</p><p>Please read it and indicate whether the policy is ready for final editing.</p>',
        poll: {
          title: 'Is the reusable packaging policy on the right track?',
          details: 'Use this sense check to identify anything that needs more work.',
          type: 'check',
          options: %w[looks_good not_sure concerned]
        }
      },
      'document_approval' => {
        title: 'Approve the reusable packaging policy',
        description: '<p>Feedback from the cooperative and cafe partners is now incorporated. The policy is ready for formal approval.</p>',
        poll: {
          title: 'Adopt the reusable packaging policy',
          details: 'Approve the policy for the six-week trial and review it when the trial ends.',
          type: 'proposal',
          options: %w[agree abstain disagree block]
        }
      },
      'document_outcome' => {
        title: 'Approve the reusable packaging policy',
        description: '<p>Feedback from the cooperative and cafe partners is now incorporated. The policy is ready for formal approval.</p>',
        poll: {
          title: 'Adopt the reusable packaging policy',
          details: 'Approve the policy for the six-week trial and review it when the trial ends.',
          type: 'proposal',
          options: %w[agree abstain disagree block]
        },
        outcome: 'The reusable packaging policy was approved for the six-week trial. We will review it with cafe partners when the trial ends.'
      },
      'thread_raise_issue' => {
        title: 'Choosing a bottle washing supplier',
        description: '<p>Our current washing setup cannot handle the expected return volume. We need to compare local suppliers before the bottle trial begins.</p><p>Share capacity, water-use, food-safety, and support requirements here.</p>',
        comments: [
          'I can request capacity and water-use figures from two suppliers.',
          'I will ask the cafe partners about their preferred collection days.'
        ]
      }
    }

    examples.fetch(kind)
  end

  def create_manual_oatmilk_closed_subgroup
    group, coordinator = create_manual_oatmilk_cooperative
    subgroup_creator = User.find_by!(email: 'samira@oatmilk.example')
    subgroup = Group.new(
      name: 'Packaging Working Group',
      description: 'Coordinate packaging suppliers, bottle returns, and labelling.',
      parent: group,
      group_privacy: 'closed',
      creator: subgroup_creator
    )
    GroupService.create(group: subgroup, actor: subgroup_creator, skip_authorize: true)

    [group, coordinator, subgroup, subgroup_creator]
  end

  def create_manual_oatmilk_invitations
    group, coordinator = create_manual_oatmilk_cooperative

    subgroups = ['Packaging Working Group', 'Cafe Partnerships'].map do |name|
      subgroup = Group.new(
        name: name,
        parent: group,
        group_privacy: 'secret',
        members_can_add_members: true,
        creator: coordinator
      )
      GroupService.create(group: subgroup, actor: coordinator)
      subgroup.add_admin!(coordinator)
      subgroup
    end

    ['casey@oatmilk.example', 'morgan@oatmilk.example'].each do |email|
      Membership.create!(
        user: User.new(email: email),
        group: group,
        inviter: coordinator,
        accepted_at: nil
      )
    end

    [group, coordinator, subgroups]
  end

  def mark_manual_oatmilk_delegates(group)
    group.memberships.joins(:user).where(users: {email: [
      'samira@oatmilk.example',
      'alex@oatmilk.example'
    ]}).update_all(delegate: true)
  end

  def create_manual_oatmilk_cooperative
    coordinator = create_manual_oatmilk_member(
      name: 'Jamie Chen',
      email: 'jamie@oatmilk.example',
      avatar_filename: 'jamie-chen.png'
    )
    production_lead = create_manual_oatmilk_member(
      name: 'Samira Patel',
      email: 'samira@oatmilk.example',
      avatar_filename: 'samira-patel.png'
    )
    sales_lead = create_manual_oatmilk_member(
      name: 'Alex Morgan',
      email: 'alex@oatmilk.example',
      avatar_filename: 'alex-morgan.png'
    )

    group = Group.new(
      name: 'Oatmilk Cooperative',
      handle: 'oatmilk-cooperative',
      description: 'We make oat milk for local cafes and shops. We use Loomio to discuss our work and make decisions together.',
      group_privacy: 'closed',
      discussion_privacy_options: 'public_or_private',
      creator: coordinator
    )
    GroupService.create(group: group, actor: coordinator)
    group.cover_photo.attach(
      io: File.open(Rails.root.join('public/theme/group_cover_photos/cover1.jpg')),
      filename: 'oatmilk-cooperative-cover.jpg'
    )
    group.logo.attach(
      io: File.open(Rails.root.join('vue/tests/e2e/fixtures/avatars/oatmilk-cooperative-logo.png')),
      filename: 'oatmilk-cooperative-logo.png'
    )
    group.add_admin!(coordinator)
    group.add_member!(production_lead)
    group.add_member!(sales_lead)

    discussion = DiscussionService.create(
      params: {
        group_id: group.id,
        title: 'Returnable bottles for cafe customers',
        description: <<~HTML,
          <p>Several cafe customers have asked whether we can supply oat milk in returnable glass bottles. This thread is for working through the practical questions before we decide whether to run a trial. 🥛</p>
          <p><strong>We need a plan that cafe staff can explain easily</strong>, including the deposit, collection days, and what happens when a bottle is damaged or not returned.</p>
          <p>Please read the <a href="https://example.com/oatmilk-bottle-return-guide">draft bottle return guide</a> and add any questions about washing capacity, food-safety checks, transport costs, or weekly reporting.</p>
        HTML
        description_format: 'html',
        private: false,
        allow_reactions: true
      },
      actor: production_lead
    )

    CommentService.create(
      comment: Comment.new(
        parent: discussion,
        body: 'I can ask three cafes to track how many bottles are returned each week.'
      ),
      actor: sales_lead
    )

    poll = PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Run a six-week returnable bottle trial',
        details: <<~HTML,
          <p>Supply returnable glass bottles to three cafe customers for six weeks, with one collection from each cafe every week.</p>
          <p><mark>Before launch, confirm the deposit guidance and the food-safety record for every washed batch.</mark></p>
          <table><thead><tr><th>Measure</th><th>Review</th></tr></thead><tbody><tr><td>Return rate</td><td>Weekly</td></tr><tr><td>Cleaning time</td><td>Each batch</td></tr><tr><td>Transport cost</td><td>End of trial</td></tr></tbody></table>
        HTML
        details_format: 'html',
        poll_type: 'proposal',
        poll_option_names: %w[agree abstain disagree block],
        closing_at: 1.week.from_now
      },
      actor: coordinator
    )
    PollService.invite(
      poll: poll,
      params: {recipient_user_ids: [production_lead.id, sales_lead.id]},
      actor: coordinator
    )

    DiscussionService.create(
      params: {
        group_id: group.id,
        title: 'Weekly production schedule',
        description: <<~HTML,
          <p>Use this thread to plan production shifts and delivery days for the coming month, including the extra work required for the bottle trial.</p>
          <blockquote><p>Keep enough time between filling and dispatch for the food-safety checks.</p></blockquote>
          <p><em>Flag any shift that still needs cover</em>, and check the <a href="https://example.com/oatmilk-delivery-calendar">shared delivery calendar</a> before confirming a route.</p>
        HTML
        description_format: 'html',
        private: false
      },
      actor: coordinator
    )

    [group, coordinator, discussion]
  end

  def create_manual_oatmilk_member(name:, email:, avatar_filename: nil)
    user = User.create!(
      name: name,
      email: email,
      password: 'password',
      detected_locale: 'en',
      email_verified: true,
      experiences: {changePicture: true, hideOnboarding: true, theme: 'light'}
    )

    if avatar_filename
      File.open(Rails.root.join('vue/tests/e2e/fixtures/avatars', avatar_filename)) do |avatar|
        user.uploaded_avatar.attach(io: avatar, filename: avatar_filename)
      end
      user.update!(avatar_kind: 'uploaded')
    end

    user
  end
end
