class API::RestfulController < API::BaseController
  @@resource_name = nil
  @@resource_plural = nil
  @@service_class = nil
  @@resource_class = nil

  class << self
    attr_writer :resource_name
    attr_writer :resource_plural
    attr_writer :service_class
    attr_writer :resource_class
  end


  def create
    begin
      instantiate_resouce
      service.create({resource_symbol => resource,
                      actor: current_user})
      respond_with_resource
    rescue
      respond_with_error
    end
  end

  def update
    begin
      load_resource
      service.update({resource_symbol => resource,
                      params: resource_params,
                      actor: current_user})
      respond_with_resource
    rescue
      respond_with_error
    end
  end

  def destroy
    begin
      load_resource
      service.destroy({resource_symbol => resource,
                       actor: current_user})
      render json: {success: 'success'}
    rescue
      respond_with_error
    end
  end

  private
  def load_and_authorize_group
    if params[:group_id]
      @group = Group.find(params[:group_id])
    elsif params[:group_key]
      @group = Group.find_by_key!(params[:group_key])
    elsif params[:id]
      @group = Group.friendly.find(params[:id])
    end
    authorize! :show, @group
  end

  def load_and_authorize_discussion
    if params[:discussion_id]
      @discussion = Discussion.find(params[:discussion_id])
    elsif params[:discussion_key]
      @discussion = Discussion.find_by_key!(params[:discussion_key])
    elsif params[:id]
      @discussion = Discussion.friendly.find(params[:id])
    end
    authorize! :show, @discussion
  end

  def collection
    instance_variable_get :"@#{resource_plural}"
  end

  def resource
    instance_variable_get :"@#{resource_name}"
  end

  def resource=(obj)
    instance_variable_set :"@#{resource_name}", obj
  end

  def instantiate_resouce
    self.resource = resource_class.new(resource_params)
  end

  def load_resource
    self.resource = resource_class.find(params[:id])
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

  def resource_class
    @@resource_class || resource_name.camelize.constantize
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
      render json: resource.errors.full_messages, root: false, status: 400
    end
  end

  def respond_with_error
    render json: ['flash.errors.aw_crap'], root: false, status: 400
  end

end
