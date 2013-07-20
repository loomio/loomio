class BaseMailer < ActionMailer::Base
  include ApplicationHelper
  include LocalesHelper
  include ERB::Util
  include ActionView::Helpers::TextHelper

  default :from => "Loomio <noreply@loomio.org>", :css => :email

  def email_subject_prefix(group_name)
    "[Loomio: #{group_name}]"
  end
end
