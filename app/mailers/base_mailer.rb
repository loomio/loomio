class BaseMailer < ActionMailer::Base
  include ERB::Util
  include ActionView::Helpers::TextHelper
  include EmailHelper
  include LocalesHelper

  helper :email
  helper :formatted_date

  # add_template_helper(PrettyUrlHelper)

  cattr_accessor :disabled
  def self.skip
    self.disabled = true
    yield
    self.disabled = false
  end

  NOTIFICATIONS_EMAIL_ADDRESS = ENV.fetch('NOTIFICATIONS_EMAIL_ADDRESS', "notifications@#{ENV['SMTP_DOMAIN']}")
  default :from => "\"#{AppConfig.theme[:site_name]}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  before_action :utm_hash


  protected
  def utm_hash
    @utm_hash = { utm_medium: 'email', utm_source: action_name, utm_campaign: mailer_name }
  end

  def group_name_prefix(model)
    model.group.present? ? "[#{model.group.handle || model.group.full_name}] " : ''
  end

  def from_user_via_loomio(user)
    "\"#{I18n.t('base_mailer.via_loomio', name: user.name, site_name: AppConfig.theme[:site_name])}\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  end

  def send_single_mail(locale: , to:, subject_key:, subject_params: {}, subject_prefix: '', **options)
    return if (to.end_with?("@example.com")) && (Rails.env.production?)
    I18n.with_locale(first_supported_locale(locale)) do
      mail options.merge(to: to, subject: subject_prefix + I18n.t(subject_key, subject_params))
    end unless self.class.disabled
  rescue Net::SMTPSyntaxError, Net::SMTPFatalError => e
    raise "SMTP error to: '#{to}' from: '#{options[:from]}' action: #{action_name} mailer: #{mailer_name} error: #{e}"
  end
end
