class Dev::BaseController < ApplicationController
  before_action :ensure_not_production

  def index
    routes = self.class.action_methods.select do |action|
      /^(test_|setup_|view_)/.match action
    end
    render Views::Dev::Main::Index.new(routes: routes)
  end

  def import_test_data
    GroupExportService.import('tmp/test.json')
    sign_in User.first
    redirect_to Group.order('memberships_count desc').first
  end

  def last_email(to: nil)
    @email = if to.present?
      ActionMailer::Base.deliveries.filter { |email| Array(email.to).include?(to.email) }
    else
      ActionMailer::Base.deliveries
    end.last
    render Views::Dev::Main::LastEmail.new(
      email: @email,
      scenario: @scenario,
      action_name: action_name
    )
  end

  private

  def redirect_to(options = {}, response_options = {})
    super
    if Rails.env.development? && response.location.present?
      uri = URI.parse(response.location)
      if uri.port == request.port
        uri.port = 8080
        response.location = uri.to_s
      end
    end
  end

  def ensure_not_production
    raise "Development and testing only" if Rails.env.production?
  end
end
