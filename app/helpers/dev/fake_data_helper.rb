module Dev::FakeDataHelper
  private

  def saved(obj)
    obj.tap(&:save!)
  end

  # only return new'd objects

  def fake_user(args = {})
    User.new({
      name: Faker::Name.name,
      email: Faker::Internet.email,
      password: 'loginlogin',
      detected_locale: 'en',
      email_verified: true,
      legal_accepted: true,
      experiences: {changePicture: true}
    }.merge(args))
  end


  def fake_unverified_user(args = {})
    User.new({
      email: Faker::Internet.email,
      email_verified: false,
    }.merge(args))
  end

  # todo fake_group ?
  def fake_group(args = {})
    name = Faker::Company.name
    Group.new({name: name, handle: name.parameterize,
      features: {use_polls: true, enable_communities: true}}.merge(args))
  end

  def fake_discussion(args = {})
    Discussion.new({title: Faker::TvShows::Friends.quote.first(150),
                    description: Faker::TvShows::Simpsons.quote,
                    private: true,
                    group: fake_group,
                    author: fake_user}.merge(args))
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
    {
      poll: option_count.times.map{ Faker::Food.ingredient },
      proposal: %w[agree abstain disagree block],
      count: %w[yes no],
      dot_vote: option_count.times.map{ Faker::Artist.name },
      meeting: option_count.times.map { |i| (seed+i).days.from_now.to_date.iso8601},
      # meeting: option_count.times.map { |i| (seed+i).hours.from_now.utc.iso8601},
      ranked_choice: option_count.times.map { Faker::Food.ingredient },
      score: option_count.times.map{ Faker::Food.ingredient }
    }.with_indifferent_access
  end

  def fake_poll(args = {})
    names = option_names(args.delete(:option_count) || 3)

    options = {
      author: fake_user,
      discussion: fake_discussion,
      poll_type: 'poll',
      title: Faker::Superhero.name,
      poll_option_names: names[args.fetch(:poll_type, :poll)],
      closing_at: 3.days.from_now,
      multiple_choice: false,
      details: with_markdown(Faker::Hipster.paragraph),
      custom_fields: {}
    }.merge args

    case options[:poll_type].to_s
    when 'dot_vote'      then options[:custom_fields][:dots_per_person] = 10
    when 'meeting'
      options[:custom_fields][:time_zone] = 'Asia/Seoul'
      options[:custom_fields][:can_respond_maybe] = true
    when 'ranked_choice' then options[:custom_fields][:minimum_stance_choices] = 2
    when 'score'         then options[:custom_fields][:max_score] = 9
    end

    Poll.new(options)
  end

  def fake_stance(args = {})
    poll = args[:poll] || saved(fake_poll)

    index = 0
    choice = if poll.minimum_stance_choices > 1
      poll.poll_options.sample(poll.minimum_stance_choices).map do |option|
        [option.name, index+=1]
      end.to_h
    elsif poll.require_all_choices
      poll.poll_options.map do |option|
        [option.name, index+=1]
      end.to_h
    else
      poll.poll_option_names.sample
    end

    Stance.new({
      poll: poll,
      participant: fake_user,
      reason: [Faker::Hipster.sentence, ""].sample,
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

  private

  def with_markdown(text)
    "#{text} - **(markdown!)**"
  end
end
