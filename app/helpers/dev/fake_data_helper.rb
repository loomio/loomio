module Dev::FakeDataHelper
  def saved(obj)
    obj.tap(&:save!)
  end

  # only return new'd objects

  def fake_user(args = {})
    User.new({
      name: Faker::Name.name,
      email: Faker::Internet.safe_email,
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
    options = {
      author: fake_user,
      discussion: fake_discussion,
      poll_type: 'poll',
      title: Faker::Superhero.name,
      poll_option_names: 5.times.map{ Faker::Food.ingredient },
      closing_at: 3.days.from_now,
      multiple_choice: false,
      details: Faker::Hipster.paragraph
    }.merge args

    if options[:poll_type] == 'proposal'
      options[:poll_option_names] = %w[agree abstain disagree block]
    end

    Poll.new(options)
  end

  def fake_outcome(args = {})
    Outcome.new({poll: poll,
                author: fake_user,
                statement: Faker::Hipster.sentence}.merge(args))
  end

end
