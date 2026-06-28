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
  include Dev::Scenarios::Profile
  include Dev::Scenarios::Tags

  before_action :reset_transient_state, except: [
    :last_email,
    :last_login_code,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
  ]
  before_action :reset_database, except: [
    :last_email,
    :last_login_code,
    :use_last_login_token,
    :index,
    :accept_last_invitation,
  ]


  def reset_transient_state
    Rails.cache.clear
  end
end
