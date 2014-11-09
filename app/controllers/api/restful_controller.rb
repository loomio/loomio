class API::RestfulController < API::BaseController
  @@resource_name = nil
  @@service_class = nil

  load_resource only: [:create, :update, :destroy]

  def create
    service.create({resource_symbol => resource,
                    actor: current_user})
    respond_with_resource
  end

  def update
    service.update({resource_symbol => resource,
                    params: resource_params,
                    actor: current_user})
    respond_with_resource
  end

  def destroy
    service.destroy({resource_symbol => resource,
                     actor: current_user})
    head :ok
  end

  private
  def resource_params
    permitted_params.send resource_name
  end

  def self.set_service(service_class)
    @@service_class = service_class
  end

  def self.set_resource_name(name)
    @@resource_name = name
  end

  def resource_symbol
    resource_name.to_sym
  end

  def resource_name
    @@resource_name || controller_name.singularize
  end

  def service
    @@service_class || "#{resource_name}_service".camelize.constantize
  end

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
    instance_variable_get :"@#{resource_name}"
  end
end
