class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include LocalesHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper
  add_template_helper(ReadableUnguessableUrlsHelper)

  UTM_EMAIL = { utm_campaign: 'notifications', utm_medium: 'email' }

  default :from => "Loomio <notifications@loomio.org>", css: :email

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end

  def initialize(method_name=nil, *args)
    super.tap do
      add_sendgrid_headers(method_name, args) if method_name
    end
  end

  private

  # Set headers for SendGrid.
  def add_sendgrid_headers(action, args)
    mailer = self.class.name
    args = Hash[ method(action).parameters.map(&:last).zip(args) ]
    headers "X-SMTPAPI" => {
      category:    [ mailer, "#{mailer}##{action}" ],
      unique_args: { environment: Rails.env, arguments: args.inspect }
    }.to_json
  end

  def from_user_via_loomio(user)
    "\"#{user.name} (Loomio)\" <notifications@loomio.org>"
  end
end
