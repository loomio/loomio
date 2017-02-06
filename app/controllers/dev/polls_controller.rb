class Dev::PollsController < Dev::BaseController
  include Dev::PollsHelper
  include Dev::NintiesMoviesHelper

  def test_activity_items
    sign_in patrick
    create_activity_items
    redirect_to discussion_url(create_discussion)
  end

  def test_proposal_created_email
    # author = FactoryGirl.create :user
    # poll   = FactoryGirl.create :poll
    poll = create_poll(poll_type: 'proposal')

    @info = PollEmailInfo.new(poll: poll,
                              recipient: patrick,
                              actor: patrick,
                              action_name: action_name)

    render 'poll_mailer/poll_created', layout: 'poll_mailer'
    # PollMailer.poll_created(poll).deliver
    # @email = ActionMailer::deliveries.last
    # render
  end

  def test_proposal_created_email
    # author = FactoryGirl.create :user
    # poll   = FactoryGirl.create :poll
    poll = create_poll(poll_type: 'proposal')

    @info = PollEmailInfo.new(poll: poll,
                              recipient: patrick,
                              actor: patrick,
                              action_name: action_name)

    render 'poll_mailer/poll_created', layout: 'poll_mailer'
    # PollMailer.poll_created(poll).deliver
    # @email = ActionMailer::deliveries.last
    # render
  end

  def test_proposal_closed_email
    sign_in patrick
    test_agree; test_disagree; test_abstain
    proposal = create_proposal.update_stance_data
    poll_email_info(poll: proposal)
    render 'poll_mailer/proposal/proposal_closed', layout: 'poll_mailer'
  end

  def test_poll_expired_email
    sign_in patrick
    create_poll(closed_at: 1.day.ago,
                closing_at: 1.day.ago)
    render 'poll_mailer/poll_expired', layout: 'poll_mailer'
  end

  def test_poll_created_email
    # author = FactoryGirl.create :user
    # poll   = FactoryGirl.create :poll
    poll = create_poll

    @info = PollEmailInfo.new(poll: poll,
                              recipient: patrick,
                              actor: patrick,
                              action_name: action_name)
    render 'poll_mailer/poll_created', layout: 'poll_mailer'
    # PollMailer.poll_created(poll).deliver
    # @email = ActionMailer::deliveries.last
    # render
  end

  # def test_poll_updated_email
  # end
  #
  # def test_poll_closing_soon_email
  # end
  #
  # def test_poll_closing_soon_yours_email
  # end
  #
  # def test_poll_expired_email
  # end
  #
  # def test_poll_outcome_created_email
  # end

  private

  def create_poll(args = {})
    group = Group.create!(name: 'group', features: {use_polls: true})
    group.add_admin! patrick
    discussion = Discussion.create!(title: 'hwllo', group: group, author: patrick, private: true)
    options = {
      author: patrick,
      discussion: discussion,
      poll_type: 'poll',
      title: Faker::Superhero.name,
      poll_option_names: 5.times.map{ Faker::Food.ingredient },
      closing_at: 3.days.from_now,
      multiple_choice: false,
      details: Faker::Hipster.paragraph
    }.merge args

    if options[:poll_type] == 'proposal'
      options[:poll_option_names] = %w[agree abstain disagree block]
      # options[:poll_option_names] = Poll::TEMPLATES.dig('proposal', 'poll_options_attributes')
    end

    poll = Poll.create!(options)
  end

  def create_activity_items
    # create poll
    options = {poll: %w[apple turnip peach],
               check_in: %w[yip nup],
               proposal: %w[agree disagree abstain block]}

    Poll::TEMPLATES.keys.each do |poll_type|
      poll = Poll.new(poll_type: poll_type,
                      title: poll_type,
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: create_discussion)
      PollService.create(poll: poll, actor: patrick)

      # edit the poll
      PollService.update(poll: poll, params: {title: 'choose!'}, actor: patrick)

      # vote on the poll
      stance = Stance.new(poll: poll,
                          stance_choices_attributes: [{poll_option_id: poll.poll_options.first.id}],
                          reason: 'democracy is in my shoes')
      StanceService.create(stance: stance, actor: patrick)

      # close the poll
      PollService.close(poll: poll, actor: patrick)

      # set an outcome
      outcome = Outcome.new(poll: poll, statement: 'We all voted')
      OutcomeService.create(outcome: outcome, actor: patrick)

      # create poll
      poll = Poll.new(poll_type: poll_type,
                      title: 'Which one?',
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: create_discussion)
      PollService.create(poll: poll, actor: patrick)
      poll.update_attribute(:closing_at, 1.day.ago)

      # expire the poll
      PollService.expire_lapsed_polls
    end

  end

end
