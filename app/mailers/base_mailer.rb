class BaseMailer < ActionMailer::Base
  include ERB::Util
  include ActionView::Helpers::TextHelper
  include EmailHelper
  include LocalesHelper

  layout false

  helper :email
  helper :formatted_date

  NOTIFICATIONS_EMAIL_ADDRESS = ENV.fetch('NOTIFICATIONS_EMAIL_ADDRESS', "notifications@#{ENV['SMTP_DOMAIN']}")
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  before_action :utm_hash

  protected
  def utm_hash
    @utm_hash = { utm_medium: 'email', utm_campaign: action_name }
  end

  def from_user_via_loomio(user)
    if user.present?
      "\"#{I18n.t('base_mailer.via_loomio', name: user.name, site_name: AppConfig.theme[:site_name])}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
    else
      "\"#{AppConfig.theme[:site_name]}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
    end
  end

  def send_email(to:, locale:, component:, **mail_options)
    return if spam?(to)

    I18n.with_locale(first_supported_locale(locale)) do
      mail(mail_options.merge(to: to, subject: yield)) do |format|
        format.html { render component }
      end
    end
  end

  def spam?(to)
    return true if NoSpam::SPAM_REGEX.match?(to)
    return true if NOTIFICATIONS_EMAIL_ADDRESS == to
    email = to.match(/<(.+)>/)&.[](1) || to
    User.has_spam_complaints.where(email: email).exists?
  end
end
