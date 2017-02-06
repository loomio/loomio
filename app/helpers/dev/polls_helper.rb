module Dev::PollsHelper
  include Dev::FakeDataHelper

  private

  def render_poll_email(poll, action_name)
    create_info(poll: poll)
    render "poll_mailer/#{action_name}", layout: 'poll_mailer'
  end

  def create_info(poll: , recipient: fake_user, actor: fake_user)
    @info = PollEmailInfo.new(poll: poll,
                              recipient: recipient,
                              actor: actor,
                              action_name: action_name)
  end

  def create_fake_poll_with_stances(args = {})
    poll = saved fake_poll(args)
    create_fake_stances(poll: poll)
    poll
  end

  def create_fake_stances(poll: )
    poll.poll_option_names.each do |name|
      (1..5).to_a.sample.times do
        poll.stances.create(poll: poll,
                           choice: name,
                           participant: fake_user,
                           reason: Faker::Hipster.sentence)
      end
    end
  end

  def create_activity_items(discussion: , actor: )
    # create poll
    options = {poll: %w[apple turnip peach],
               check_in: %w[yip nup],
               proposal: %w[agree disagree abstain block]}

    Poll::TEMPLATES.keys.each do |poll_type|
      poll = Poll.new(poll_type: poll_type,
                      title: poll_type,
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: discussion)
      PollService.create(poll: poll, actor: actor)

      # edit the poll
      PollService.update(poll: poll, params: {title: 'choose!'}, actor: actor)

      # vote on the poll
      stance = Stance.new(poll: poll,
                          choice: poll.poll_option_names.first,
                          reason: 'democracy is in my shoes')
      StanceService.create(stance: stance, actor: actor)

      # close the poll
      PollService.close(poll: poll, actor: actor)

      # set an outcome
      outcome = Outcome.new(poll: poll, statement: 'We all voted')
      OutcomeService.create(outcome: outcome, actor: actor)

      # create poll
      poll = Poll.new(poll_type: poll_type,
                      title: 'Which one?',
                      details: 'fine print',
                      poll_option_names: options[poll_type.to_sym],
                      discussion: discussion)
      PollService.create(poll: poll, actor: actor)
      poll.update_attribute(:closing_at, 1.day.ago)

      # expire the poll
      PollService.expire_lapsed_polls
    end
  end
end
