class API::RestfulController < API::BaseController
  load_and_authorize_resource only: :show,  find_by: :key
  load_resource only: [:create, :update, :destroy], param_method: :permitted_params

  before_filter :set_author, only: :create

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

  def set_author
    resource.author ||= current_user
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params, current_user).send(:"api_#{controller_name.singularize}")
  end

end