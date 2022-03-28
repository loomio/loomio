module Dev::FakeDataHelper
  private

  def saved(obj)
    obj.tap(&:save!)
  end

  # only return new'd objects
  def fake_user(args = {})
    u = User.new({
      name: [Faker::Name.name,
             Faker::TvShows::RuPaul.queen,
             Faker::Superhero.name,
             Faker::TvShows::BojackHorseman.character,
             Faker::Movies::BackToTheFuture.character].sample.truncate(100),
      email: Faker::Internet.email,
      password: 'loginlogin',
      detected_locale: 'en',
      email_verified: true,
      legal_accepted: true,
      experiences: {changePicture: true}
    }.merge(args))
    # # u.attach io: open(Faker::Avatar.image)
    # u.uploaded_avatar.attach io: File.new("#{Rails.root}/spec/fixtures/images/patrick.png"), filename: 'patrick.jpg'
    # u.update(avatar_kind: :uploaded)
    u

  end

  def fake_unverified_user(args = {})
    User.new({
      email: Faker::Internet.email,
      email_verified: false,
    }.merge(args))
  end

  def fake_group(args = {})
    defaults = {
      name: Faker::Company.name,
      description: [
        Faker::TvShows::BojackHorseman.quote,
        Faker::Movies::BackToTheFuture.quote].sample
    }

    values = defaults.merge(args)
    values[:handle] = values[:name].parameterize
    group = Group.new(values)
    group.tags = [fake_tag]

    # puts 'attaching'
    # group.logo.attach(
    #   io: URI.open(Rails.root.join('public/brand/icon_sky_300h.png')),
    #   filename: 'loomiologo.png',
    #   identify: false,
    #   content_type: 'image/png'
    # )
    # puts 'attached'
    # group.cover_photo.attach(io: URI.open(Rails.root.join('public/brand/logo_sky_256h.png')), filename: 'loomiocover.png')

    group
  end

  def fake_tag(args = {})
    defaults = {
      name: Faker::Space.planet,
      color: Faker::Color.hex_color
    }
    Tag.new(defaults.merge(args))
  end

  def fake_discussion(args = {})
    Discussion.new({
      title: [Faker::TvShows::BojackHorseman.tongue_twister,
              Faker::TvShows::Friends.quote,
              Faker::Quote.yoda,
              Faker::Quote.robin].sample.truncate(150),
      description: [Faker::TvShows::BojackHorseman.quote,
                    Faker::TvShows::Simpsons.quote,
                    Faker::Quote.famous_last_words].sample,
      private: true,
      group: fake_group,
      author: fake_user}.merge(args))
  end


  def fake_new_discussion_event(discussion = fake_discussion)
    Events::NewDiscussion.new(
      user: discussion.author,
      kind: 'new_discussion',
      eventable: discussion
    )
  end

  def fake_poll_created_event(poll = fake_poll)
    Events::PollCreated.new(
      user: poll.author,
      kind: 'poll_created',
      eventable: poll,
      discussion: poll.discussion
    )
  end

  def fake_stance_created_event(stance = fake_stance)
    Events::StanceCreated.new(
      user_id: stance[:participant_id],
      kind: 'stance_created',
      eventable: stance,
      discussion: stance.poll.discussion
    )
  end

  def fake_outcome_created_event(outcome = fake_outcome)
    Events::OutcomeCreated.new(
      user_id: outcome.author_id,
      kind: 'outcome_created',
      eventable: outcome,
      discussion: outcome.discussion
    )
  end

  def fake_membership(args = {})
    Membership.new({
      group: fake_group,
      user: fake_user,
    }.merge(args))
  end

  def fake_membership_request(args = {})
    MembershipRequest.new({
      requestor: fake_user,
      group: fake_group
    }.merge(args))
  end

  def fake_identity(args = {})
    Identities::Base.new({
      user: fake_user,
      uid: "abc",
      access_token: SecureRandom.uuid,
      identity_type: :slack
    }.merge(args))
  end

  def option_names(option_count)
    seed = (0..20).to_a.sample
    options = option_count.times.map do
      [
        Faker::Food.ingredient,
        Faker::Movies::StarWars.call_squadron
      ].sample.truncate(250)
    end
    {
      poll: options,
      proposal: %w[agree abstain disagree block],
      count: %w[yes no],
      dot_vote: options,
      meeting: option_count.times.map { |i| (seed+i).days.from_now.to_date.iso8601},
      ranked_choice: options,
      score: options
    }.with_indifferent_access
  end

  def fake_poll(args = {})
    names = option_names(args.delete(:option_count) || (2..7).to_a.sample)

    closing_at = args[:wip] ? nil : 3.days.from_now
    options = {
      author: fake_user,
      discussion: fake_discussion,
      poll_type: 'poll',
      title: [Faker::Superhero.name, Faker::Movies::StarWars.quote].sample.truncate(140),
      details: [
        Faker::Movies::StarWars.quote,
        Faker::Movies::HitchhikersGuideToTheGalaxy.marvin_quote,
        Faker::Movies::PrincessBride.quote,
        Faker::Movies::Lebowski.quote,
        Faker::Movies::HitchhikersGuideToTheGalaxy.quote].sample,
      poll_option_names: names[args.fetch(:poll_type, :poll)],
      closing_at: closing_at,
      multiple_choice: false,
      specified_voters_only: false,
      custom_fields: {}
    }.merge args.tap {|a| a.delete(:wip)}

    case options[:poll_type].to_s
    when 'dot_vote'
      options[:custom_fields][:dots_per_person] = 10
    when 'meeting'
      options[:custom_fields][:time_zone] = 'Asia/Seoul'
      options[:custom_fields][:can_respond_maybe] = true
    when 'ranked_choice'
      options[:custom_fields][:minimum_stance_choices] = 3
    when 'score'
      options[:custom_fields][:max_score] = 9
      options[:custom_fields][:min_score] = -9
    end

    Poll.new(options)
  end


  def fake_score(poll)
    case poll.poll_type
    when 'score'
      ((poll.min_score)..(poll.max_score)).to_a.sample
    when 'ranked_choice'
      (1..8).to_a.sample
    when 'meeting'
      if poll.can_respond_maybe
        [0,1,2].sample
      else
        [0,1].sample
      end
    else
      1
    end
  end

  def fake_stance(args = {})
    poll = args[:poll] || saved(fake_poll)

    choice = if poll.minimum_stance_choices > 1
      poll.poll_options.sample(poll.minimum_stance_choices).map do |option|
        [option.name, fake_score(poll)]
      end.to_h
    elsif poll.require_all_choices
      poll.poll_options.map do |option|
        [option.name, fake_score(poll)]
      end.to_h
    else
      poll.poll_option_names.sample
    end

    Stance.new({
      poll: poll,
      participant: fake_user,
      reason: [
        Faker::Hipster.sentence,
        Faker::GreekPhilosophers.quote,
        Faker::TvShows::RuPaul.quote,
        ""].sample,
      choice: choice
    }.merge(args))
  end

  def fake_comment(args = {})
    Comment.new({
      discussion: fake_discussion,
      body: Faker::ChuckNorris.fact,
      author: fake_user
    }.merge(args))
  end

  def fake_reaction(args = {})
    Reaction.new({
      reactable: fake_comment,
      user: fake_user,
      reaction: "+1"
    }.merge(args))
  end

  def fake_outcome(args = {})
    poll = fake_poll
    Outcome.new({
      poll: poll,
      author: poll.author,
      statement: with_markdown(Faker::Hipster.sentence)
    }.merge(args))
  end

  def fake_received_email(args = {})
    ReceivedEmail.new({
      sender_email: Faker::Internet.email,
      subject: Faker::ChuckNorris.fact,
      body: "FORWARDED MESSAGE------ TO: Mary <mary@example.com>, beth@example.com, Tim <tim@example.com> SUBJECT: We're having an argument! blahblahblah",
    })
  end

  def create_fake_poll_with_stances(args = {})
    poll = saved fake_poll(args)
    create_fake_stances(poll: poll)
    poll
  end

  def create_group_with_members
    group = saved(fake_group)
    group.add_admin!(saved(fake_user))
    (7..9).to_a.sample.times do 
      group.add_member!(saved(fake_user))
    end
    group
  end

  def create_fake_poll_in_group(args = {})
    saved(build_fake_poll_in_group)
  end

  def create_fake_stances(poll:)
    (2..7).to_a.sample.times do
      u = fake_user
      poll.group.add_member!(u) if poll.group
      stance = fake_stance(poll: poll)
      stance.save!
    end
    poll.update_counts!
  end

  def create_discussion_with_nested_comments
    group = create_group_with_members
    group.reload
    discussion    = saved fake_discussion(group: group)
    DiscussionService.create(discussion: discussion, actor: group.admins.first)

    15.times do
      parent_author = fake_user
      group.add_member! parent_author
      parent = fake_comment(discussion: discussion)
      CommentService.create(comment: parent, actor: parent_author)

      (0..3).to_a.sample.times do
        reply_author = fake_user
        group.add_member! reply_author
        reply = fake_comment(discussion: discussion, parent: parent)
        CommentService.create(comment: reply, actor: reply_author)
      end
    end

    discussion.reload
    EventService.repair_thread(discussion.id)
    discussion.reload
  end

  def create_discussion_with_sampled_comments
    group = create_group_with_members

    discussion = saved fake_discussion(group: group)
    DiscussionService.create(discussion: discussion, actor: group.admins.first)
    discussion.update(max_depth: 3)

    5.times do
      group.add_member! saved(fake_user)
    end

    10.times do
      CommentService.create(comment: fake_comment(discussion: discussion), actor: group.members.sample)
    end
    comments = discussion.reload.comments

    10.times do
      CommentService.create(comment: fake_comment(discussion: discussion, parent: comments.sample), actor: group.members.sample)
    end

    comments = discussion.reload.comments

    10.times do
      CommentService.create(comment: fake_comment(discussion: discussion, parent: comments.sample), actor: group.members.sample)
    end

    discussion.reload
    EventService.repair_thread(discussion.id)
    discussion.reload
    discussion
  end


  private

  def with_markdown(text)
    "#{text} - **(markdown!)**"
  end
end
