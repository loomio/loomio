module Dev::FakeDataHelper
  def saved(obj)
    obj.tap(&:save!)
  end

  # only return new'd objects

  def fake_user(args = {})
    User.new({
      name: Faker::Name.name,
      email: Faker::Internet.email,
      password: Faker::Internet.password,
      detected_locale: 'en',
      is_admin: true,
      email_verified: true,
      experiences: {enable_communities: true}
    }.merge(args))
  end

  # todo fake_formal_group ?
  def fake_group(args = {})
    FormalGroup.new({name: Faker::Company.name,
      features: {use_polls: true, enable_communities: true}}.merge(args))
  end

  def fake_discussion(args = {})
    Discussion.new({title: Faker::Friends.quote.first(150),
                    private: true,
                    group: fake_group,
                    author: fake_user}.merge(args))
  end

  def fake_invitation(args = {})
    Invitation.new({
      group: fake_group,
      recipient_email: Faker::Internet.email
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

  def fake_draft(args = {})
    Draft.new({
      draftable: fake_group
    }.merge(args))
  end

  def option_names
    seed = (0..20).to_a.sample
    {
      poll: 3.times.map{ Faker::Food.ingredient },
      proposal: %w[agree abstain disagree block],
      count: %w[yes no],
      dot_vote: 3.times.map{ Faker::Artist.name },
      meeting: 3.times.map { |i| (seed+i).days.from_now.to_date } + 3.times.map { |i| (seed+i).days.from_now.beginning_of_hour.utc.iso8601 },
      ranked_choice: 3.times.map { Faker::Food.ingredient }
    }.with_indifferent_access
  end

  def fake_poll(args = {})
    options = {
      author: fake_user,
      discussion: fake_discussion,
      poll_type: 'poll',
      title: Faker::Superhero.name,
      poll_option_names: option_names[args.fetch(:poll_type, :poll)],
      closing_at: 3.days.from_now,
      multiple_choice: false,
      details: with_markdown(Faker::Hipster.paragraph),
      custom_fields: {}
    }.merge args

    case options[:poll_type].to_s
    when 'dot_vote'      then options[:custom_fields][:dots_per_person] = 10
    when 'meeting'       then options[:custom_fields][:time_zone] = 'Asia/Seoul'
    when 'ranked_choice' then options[:custom_fields][:minimum_stance_choices] = 2
    end

    Poll.new(options)
  end

  def fake_stance(args = {})
    poll = args[:poll] || saved(fake_poll)
    choices = 1..poll.minimum_stance_choices      

    Stance.new({
      poll: poll,
      participant: fake_user,
      reason: Faker::Hacker.say_something_smart,
      stance_choices_attributes: choices.map { |i| { poll_option_id: poll.poll_option_ids[i] } }
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
