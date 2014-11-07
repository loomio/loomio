class API::RestfulController < API::BaseController
  #check_authorization
  #load_and_authorize_resource only: :show, find_by: :key
  #load_resource only: [:update, :destroy], param_method: :permitted_params

  #def show
    #respond_with_resource
  #end

  private

  def respond_with_collection
    render json: collection
  end

  def respond_with_resource
    if resource.errors.empty?
      render json: [resource]
    else
      render json: { errors: resource.errors }, status: 400
    end
  end

  def collection
    instance_variable_get :"@#{controller_name}"
  end

  def resource
    instance_variable_get :"@#{controller_name.singularize}"
  end
end
