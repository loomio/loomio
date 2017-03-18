class API::RegistrationsController < Devise::RegistrationsController
  include DeviseControllerHelper

  def create
    if params[resource_name][:honeypot]
      head :bad_request
    else
      super
    end
  end

  private

  def respond_with(resource, args = {})
    if resource.persisted?
      flash[:notice] = t(:'devise.registrations.signed_up')
      render json: BootData.new(resource).data
    else
      render json: { errors: resource.errors }, status: 422
    end
  end
end
