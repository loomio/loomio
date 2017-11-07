class Dev::BaseController < ApplicationController
  before_filter :ensure_not_production
  before_filter :cleanup_database
  around_filter :dont_send_emails

  def index
    @routes = self.class.action_methods.select do |action|
      /^(test_|setup_)/.match action
    end
    render 'dev/main/index', layout: false
  end

  def last_email(to: nil)
    @email = if to.present?
      ActionMailer::Base.deliveries.select { |email| Array(email.to).include?(to.email) }
    else
      ActionMailer::Base.deliveries
    end.last
    render template: 'dev/main/last_email', layout: false
  end

  private
  def ensure_not_production
    raise "Development and testing only" if Rails.env.production?
  end

  def cleanup_database
    reset_session
    User.delete_all
    Group.delete_all
    Membership.delete_all
    Poll.delete_all
    ActionMailer::Base.deliveries = []
  end

  def dont_send_emails
    BaseMailer.skip { yield }
  end
end
