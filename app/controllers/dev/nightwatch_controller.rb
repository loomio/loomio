class Dev::NightwatchController < Dev::BaseController
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
  include Dev::Scenarios::Profile
  # include Dev::Scenarios::Legacy

  before_action :cleanup_database, except: [
    :last_email,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
  ]

  around_action :dont_send_emails, except: [
    :setup_discussion_mailer_new_discussion_email,
    :setup_discussion_mailer_new_comment_email,
    :setup_discussion_mailer_user_mentioned_email,
    :setup_discussion_mailer_invitation_created_email,
    :setup_accounts_merged_email,
    :setup_thread_catch_up,
    :setup_group_invitation_ignored,
    :setup_discussion_invitation_ignored,
    :setup_poll_invitation_ignored,
    :setup_user_reactivation_email
  ]
end
