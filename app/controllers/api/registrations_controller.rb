class API::RegistrationsController < Devise::RegistrationsController
  include PendingActionsHelper

  private

  def respond_with(resource, args = {})
    if resource.persisted?
      handle_pending_actions
      flash[:notice] = t(:'devise.registrations.signed_up')
      render json: BootData.new(resource).data
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  def sign_up_params
    params.require(:user).permit(:name, :email, :recaptcha).tap { |p| p.require(:recaptcha) }
  end
end
