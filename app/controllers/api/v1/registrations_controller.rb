class Api::V1::RegistrationsController < ApplicationController
  include LocalesHelper
  allow_unauthenticated_access only: %i[ create ]
  before_action :permission_check, only: :create

  def create
    @email_can_be_verified = email_can_be_verified?
    @user = UserService.create(params: sign_up_params)
    if !@user.errors.any?
      save_detected_locale(@user)
      if @email_can_be_verified
        sign_in @user
        flash[:notice] = t(:'devise.sessions.signed_in')
        render json: Boot::User.new(@user, root_url: URI(root_url).origin).payload.merge({ success: :ok, signed_in: true })
      else
        LoginTokenService.create(actor: @user, uri: URI::parse(request.referrer.to_s))
        render json: { success: :ok, signed_in: false }
      end
      EventBus.broadcast('registration_create', @user)
    else
      render json: { errors: @user.errors }, status: 422
    end
  rescue UserService::EmailTakenError => e
    render json: {errors: {email: [I18n.t('auth_form.email_taken')]}}, status: 422
  end

  private
  def email_can_be_verified?
    (pending_membership&.user  ||
     pending_login_token&.user ||
     pending_discussion_reader&.user ||
     pending_stance&.user ||
     pending_identity)&.email == sign_up_params[:email]
  end

  def pending_user
    user = (pending_membership || pending_login_token || pending_identity)&.user
    user if user && !user.email_verified?
  end

  def permission_check
    if !(AppConfig.app_features[:create_user] || pending_invitation || pending_group)
      render json: { errors: {email: [I18n.t('auth_form.invitation_required')], name: [I18n.t('auth_form.invitation_required')]}}, status: 422
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :legal_accepted, :email_newsletter)
  end
end
