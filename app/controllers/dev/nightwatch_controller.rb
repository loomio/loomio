require_relative Rails.root.join('test/reset_database_helper')
class Dev::NightwatchController < Dev::BaseController
  include ResetDatabaseHelper
  include Dev::NintiesMoviesHelper
  include PrettyUrlHelper

  include Dev::Scenarios::Util
  include Dev::Scenarios::Auth
  include Dev::Scenarios::Dashboard
  include Dev::Scenarios::Discussion
  include Dev::Scenarios::EmailSettings
  include Dev::Scenarios::Group
  include Dev::Scenarios::Inbox
  include Dev::Scenarios::JoinGroup
  include Dev::Scenarios::MembershipRequest
  include Dev::Scenarios::Membership
  include Dev::Scenarios::Notification
  include Dev::Scenarios::OatmilkCooperative
  include Dev::Scenarios::Profile
  include Dev::Scenarios::Tags

  around_action :deliver_preview_emails_inline, if: -> { action_name.include?('_mailer_') }

  before_action :reset_transient_state, except: [
    :last_email,
    :last_login_code,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
    :revoke_secret_group_access,
    :view_email_catch_up_settings,
    :view_thread_email_settings,
  ]
  before_action :reset_database, except: [
    :last_email,
    :last_login_code,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
    :revoke_secret_group_access,
    :view_email_catch_up_settings,
    :view_thread_email_settings,
  ]


  def reset_transient_state
    Rails.cache.clear
    ActionMailer::Base.deliveries.clear
    flash.clear
  end

  private

  # Mail previews read in-process deliveries, so their jobs must finish in the request.
  def deliver_preview_emails_inline
    previous_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :inline
    yield
  ensure
    ActiveJob::Base.queue_adapter = previous_adapter
  end
end
