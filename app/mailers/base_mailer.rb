class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include LocalesHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper
  include EmailHelper
  #include Roadie::Rails::Mailer
  include Roadie::Rails::Automatic

  add_template_helper(ReadableUnguessableUrlsHelper)

  UTM_EMAIL = { utm_campaign: 'notifications', utm_medium: 'email' }

  default :from => "Loomio <notifications@loomio.org>"

  protected

  def roadie_options
    super.merge(url_options: {host: ActionMailer::Base.default_url_options[:host]})
  end

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end

  def initialize(method_name=nil, *args)
    super.tap do
      add_sendgrid_headers(method_name, args) if method_name
    end
  end

  # Set headers for SendGrid.
  def add_sendgrid_headers(action, args)
    mailer = self.class.name
    args = Hash[ method(action).parameters.map(&:last).zip(args) ]
    headers "X-SMTPAPI" => {
      category:    [ mailer, "#{mailer}##{action}" ]
    }.to_json
  end

  def from_user_via_loomio(user)
    "\"#{user.name} (Loomio)\" <notifications@loomio.org>"
  end
end
