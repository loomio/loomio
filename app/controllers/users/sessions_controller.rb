class Users::SessionsController < Devise::SessionsController
  layout 'pages'
  include AutodetectTimeZone
  include InvitationsHelper
  include OmniauthAuthenticationHelper

  # at some point in the future we can remove this
  before_filter :create_parse_user_if_needed, only: :create

  before_filter :store_previous_location, only: :new
  before_filter :load_invitation_from_session, only: :new
  after_filter :set_time_zone_from_javascript, only: :create

  private

  # and this
  def create_parse_user_if_needed
    return unless need_to_create_parse_user?
    Group.find(ENV['PARSE_GROUP_ID']).add_member! parsed_user
    sign_in :user, parsed_user
    flash[:notice] = t(:'devise.sessions.signed_in')
    redirect_to after_sign_in_path_for parsed_user
  end

  private

  def need_to_create_parse_user?
    ENV['PARSE_ID'] &&
    request.subdomain == ENV['PARSE_SUBDOMAIN'] &&
    !warden.authenticate?(auth_options) &&
    user_hash.present?
  end

  def user_hash
    @user_hash ||= ParseAuth.login_with_email_and_password(params[:user][:email], params[:user][:password])
  end

  def parsed_user
    @parsed_user ||= 
      User.find_by_email(params[:user][:email]) || 
      User.create! name: "#{user_hash['firstname']} #{user_hash['lastname']}", 
                   email: params[:user][:email], 
                   password: params[:user][:password]
  end
end
