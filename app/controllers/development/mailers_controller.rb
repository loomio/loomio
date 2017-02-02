class Development::MailersController < Development::BaseController
  include Development::PollsHelper
  include Development::NintiesMoviesHelper

  def index
    @routes = self.class.action_methods.select do |action|
      action.starts_with? 'setup'
    end
    render layout: false, template: 'development/index'
  end

  def setup_poll_created
    # author = FactoryGirl.create :user
    # poll   = FactoryGirl.create :poll

    poll = Poll.create!(author: patrick,
                        poll_type: 'poll',
                        title: "test",
                        poll_option_names: ['one', 'tow'],
                        closing_at: 3.days.from_now,
                        details: 'hello')


    poll_email_info(poll: poll, actor: patrick)


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

end
