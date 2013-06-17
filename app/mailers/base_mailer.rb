class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper

  default :from => "Loomio <noreply@loomio.org>", :css => :email

  def set_email_locale(preference, fallback)
    if preference.present?
      I18n.locale = preference
    elsif fallback.present?
      I18n.locale = fallback
    elsif preference.blank? && fallback.blank?
      I18n.locale = I18n.default_locale
    end
  end

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end
end
