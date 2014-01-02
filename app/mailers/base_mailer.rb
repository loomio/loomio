class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include LocalesHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper
  UTM_EMAIL = { utm_campaign: 'notifications', utm_medium: 'email' }

  default :from => "Loomio <noreply@loomio.org>", :css => :email

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

  def replyable_email(recipient: nil, replyable: nil, default_email: nil)
    if ENV['REPLY_TO_EMAIL']
      token = ReplyToken.create(user: recipient, replyable: replyable).token
      inject_reply_token(token, ENV['REPLY_TO_EMAIL'])
    else
      default_email
    end
  end

  def inject_reply_token(token, email)
    email.gsub "@", "+#{token}@"
  end
end
