class BaseMailer < ActionMailer::Base
  include ERB::Util
  include ActionView::Helpers::TextHelper
  include EmailHelper

  helper :email

  add_template_helper(PrettyUrlHelper)

  NOTIFICATIONS_EMAIL_ADDRESS = "notifications@#{ENV['SMTP_DOMAIN']}"
  default :from => "Loomio <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  before_action :utm_hash

  protected
  def utm_hash
    @utm_hash = { utm_medium: 'email', utm_source: action_name, utm_campaign: mailer_name }
  end

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end

  def from_user_via_loomio(user)
    "\"#{user.name} (Loomio)\" <#{NOTIFICATIONS_EMAIL_ADDRESS}>"
  end

  def send_single_mail(locale: , to:, subject_key:, subject_params: {}, **options)
    I18n.with_locale(locale) do
      mail options.merge(to: to, subject: I18n.t(subject_key, subject_params))
    end
  rescue Net::SMTPSyntaxError, Net::SMTPFatalError => e
    raise "SMTP error to: '#{to}' from: '#{options[:from]}' action: #{action_name} mailer: #{mailer_name} error: #{e}"
  end

  def locale_for(*user)
    [*user, I18n].compact.first.locale
  end

  def self.send_bulk_mail(to:)
    to.each { |user| yield user if block_given? }
  end
end
