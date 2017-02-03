class Development::MailersController < Development::BaseController
  include Development::PollsHelper
  include Development::NintiesMoviesHelper

  def index
    @routes = self.class.action_methods.select do |action|
      action.starts_with? 'setup'
    end
    render layout: false, template: 'development/index'
  end

  def setup_proposal_created
    # author = FactoryGirl.create :user
    # poll   = FactoryGirl.create :poll
    poll = generate_poll(poll_type: 'proposal')

    @info = PollEmailInfo.new(poll: poll,
                              recipient: patrick,
                              actor: patrick,
                              action_name: action_name)

    render 'poll_mailer/poll_created', layout: 'poll_mailer'
    # PollMailer.poll_created(poll).deliver
    # @email = ActionMailer::deliveries.last
    # render
  end

  def setup_poll_created
    # author = FactoryGirl.create :user
    # poll   = FactoryGirl.create :poll
    poll = generate_poll

    @info = PollEmailInfo.new(poll: poll,
                              recipient: patrick,
                              actor: patrick,
                              action_name: action_name)
    render 'poll_mailer/poll_created', layout: 'poll_mailer'
    # PollMailer.poll_created(poll).deliver
    # @email = ActionMailer::deliveries.last
    # render
  end

  def setup_poll_update
  end

  def setup_poll_closing_soon
  end

  def setup_poll_closing_soon_yours
  end

  def setup_poll_expired
  end

  def setup_poll_outcome_created
  end

  private

  def generate_poll(args = {})
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

end
