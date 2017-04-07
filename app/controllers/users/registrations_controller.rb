class Users::RegistrationsController < Devise::RegistrationsController
  include DeviseControllerHelper

  before_filter :store_group_key_to_session, only: :new
  before_filter :redirect_if_robot, only: :create
  before_filter :load_omniauth_authentication_from_session, only: :new

  def new
    @invitation = invitation_from_session
    @user = User.new(
      name:  @omniauth_authentication&.name  || invitation_from_session&.recipient_name,
      email: @omniauth_authentication&.email || invitation_from_session&.recipient_email
    )
  end

  private

  def sign_up(resource_name, resource)
    super(resource_name, resource)
    load_omniauth_authentication_from_session.update(user: resource) if omniauth_authenticated_and_waiting?
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
