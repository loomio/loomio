class Users::RegistrationsController < Devise::RegistrationsController
  include DeviseControllerHelper

  before_filter :store_group_key_to_session, only: :new
  before_filter :redirect_if_robot, only: :create
  before_filter :load_invitation_from_session, only: :new

  after_filter :set_time_zone_from_javascript, only: [:create]

  def new
    @user = User.new
    if @invitation
      if @invitation.intent == 'start_group'
        @user.name = @invitation.recipient_name
        @user.email = @invitation.recipient_email
      else
        @user.email = @invitation.recipient_email
      end
    end

    if omniauth_authenticated_and_waiting?
      load_omniauth_authentication_from_session
      @user.name = @omniauth_authentication.name
      @user.email = @omniauth_authentication.email
    end
  end

  private

  def sign_up(resource_name, resource)
    super(resource_name, resource)

    if omniauth_authenticated_and_waiting?
      load_omniauth_authentication_from_session
      @omniauth_authentication.update(user: resource)
    end
  end

  def store_group_key_to_session
    session[:group_key] = params[:group_key]
  end

  def redirect_if_robot
    if params[:user][:honeypot].present?
      flash[:warning] = t(:honeypot_warning)
      redirect_to new_user_registration_path
    else
      params[:user] = params[:user].except(:honeypot)
    end
  end
end
