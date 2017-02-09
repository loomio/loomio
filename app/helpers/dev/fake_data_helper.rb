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
      detected_locale: 'en'
    }.merge(args))
  end

  def fake_group(args = {})
    Group.new({name: Faker::Company.name,
      features: {use_polls: true}}.merge(args))
  end

  def fake_discussion(args = {})
    Discussion.new({title: Faker::Friends.quote,
                    private: true,
                    group: fake_group,
                    author: fake_user}.merge(args))
  end

  def fake_poll(args = {})
    option_names = {
      poll: 3.times.map{ Faker::Food.ingredient },
      proposal: %w[agree abstain disagree block],
      check_in: %w[accept decline]
    }.with_indifferent_access

    options = {
      author: fake_user,
      discussion: fake_discussion,
      poll_type: 'poll',
      title: Faker::Superhero.name,
      poll_option_names: option_names[args.fetch(:poll_type, :poll)],
      closing_at: 3.days.from_now,
      multiple_choice: false,
      details: Faker::Hipster.paragraph
    }.merge args

    Poll.new(options)
  end

  def fake_outcome(args = {})
    poll = fake_poll
    Outcome.new({poll: poll,
                author: poll.author,
                statement: Faker::Hipster.sentence}.merge(args))
  end

end
