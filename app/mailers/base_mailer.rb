class BaseMailer < ActionMailer::Base
  include ERB::Util
  include ActionView::Helpers::TextHelper
  include EmailHelper
  include LocalesHelper

  helper :email
  helper :formatted_date

  # add_template_helper(PrettyUrlHelper)

  NOTIFICATIONS_EMAIL_ADDRESS = ENV.fetch('NOTIFICATIONS_EMAIL_ADDRESS', "notifications@#{ENV['SMTP_DOMAIN']}")
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  before_action :utm_hash

  def contact_message(name, email, subject, body, details = {})
    @details = details
    @body = body
    mail(
      to: ENV['SUPPORT_EMAIL'],
      reply_to: "\"#{name}\" <#{email}>",
      subject: subject,
    )
  end

  protected
  def utm_hash
    @utm_hash = { utm_medium: 'email', utm_campaign: action_name }
  end


  def from_user_via_loomio(user)
    "\"#{I18n.t('base_mailer.via_loomio', name: user.name, site_name: AppConfig.theme[:site_name])}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  end

  def send_single_mail(locale: , to:, subject_key:, subject_params: {}, subject_prefix: '', subject_is_title: false, **options)
    return if ENV['SPAM_REGEX'] && Regexp.new(ENV['SPAM_REGEX']).match(to)
    return if User::BOT_EMAILS.values.include?(to)
    return if (to.end_with?("@example.com")) && (Rails.env.production?)

    I18n.with_locale(first_supported_locale(locale)) do
      if subject_is_title
        subject = subject_prefix + subject_params[:title]
      else
        subject = subject_prefix + I18n.t(subject_key, subject_params)
      end
      mail options.merge(to: to, subject: subject )
    end
  rescue Net::SMTPSyntaxError, Net::SMTPFatalError => e
    raise "SMTP error to: '#{to}' from: '#{options[:from]}' action: #{action_name} mailer: #{mailer_name} error: #{e}"
  end
end
