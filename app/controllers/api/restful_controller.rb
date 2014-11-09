class API::RestfulController < API::BaseController
  @@resource_name = nil
  @@resource_plural = nil
  @@service_class = nil

  class << self
    attr_writer :resource_name
    attr_writer :resource_plural
    attr_writer :service_class
  end

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
    respond_with_command Commands::DeleteRecord.new(resource)
  end

  private
  def respond_with_command(command)
    render json: {command: command.to_json}
  end

  def resource_params
    permitted_params.send resource_name
  end

  def resource_symbol
    resource_name.to_sym
  end

  def resource_name
    @@resource_name || controller_name.singularize
  end

  def resource_plural
    @@resource_plural || controller_name
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
    instance_variable_get :"@#{resource_plural}"
  end

  def resource
    instance_variable_get :"@#{resource_name}"
  end
end
