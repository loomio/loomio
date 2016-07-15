class API::RegistrationsController < Devise::RegistrationsController
  include DeviseControllerHelper

  private

  def respond_with(resource, args = {})
    if resource.persisted?
      flash[:notice] = t(:'devise.registrations.signed_up')
      render json: CurrentUserSerializer.new(resource).as_json
    else
      render json: { errors: resource.errors }, status: 422
    end
  end
end
