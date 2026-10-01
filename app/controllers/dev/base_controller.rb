class Dev::BaseController < ApplicationController
  before_action :ensure_not_production
  after_action :set_screenshot_locale

  def index
    controllers = if self.class == Dev::NightwatchController
      {nightwatch: Dev::NightwatchController, discussions: Dev::DiscussionsController, polls: Dev::PollsController}
    else
      {controller_name.to_sym => self.class}
    end
    routes = controllers.flat_map do |namespace, controller|
      controller.action_methods.grep(/\A(?:test_|setup_|view_)/).map { |action| "/dev/#{namespace}/#{action}" }
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

  # The optional screenshot runner uses only the isolated test application.
  # Persist its selected locale before the scenario redirect loads Vue.
  def set_screenshot_locale
    return unless Rails.env.test? && ENV.key?("DOCS_SCREENSHOT_APP_LOCALE")
    return unless current_user.is_logged_in?

    current_user.update_columns(selected_locale: ENV.fetch("DOCS_SCREENSHOT_APP_LOCALE"))
  end

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
