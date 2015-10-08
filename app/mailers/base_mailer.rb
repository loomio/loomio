class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include LocalesHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper
  include EmailHelper
  include Roadie::Rails::Automatic

  add_template_helper(ReadableUnguessableUrlsHelper)

  default :from => "Loomio <notifications@loomio.org>"
  before_action :utm_hash

  protected
  def utm_hash
    @utm_hash = { utm_medium: 'email', utm_source: action_name, utm_campaign: mailer_name }
  end

  def roadie_options
    super.merge(url_options: {host: ActionMailer::Base.default_url_options[:host]})
  end

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end

  def from_user_via_loomio(user)
    "\"#{user.name} (Loomio)\" <notifications@loomio.org>"
  end

  def send_single_mail(locale: I18n.locale, to:, subject:, **options)
    I18n.with_locale(locale) { mail options.merge(to: self.class.interceptor_email || to, subject: subject) }
  end

  def self.send_bulk_mail(to:)
    to = Array(User.loomio_helper_bot) if interceptor_email.present?
    to.each { |email| yield email if block_given? }
  end

  def self.interceptor_email
    ENV['INTERCEPTOR_EMAIL']
  end
end
