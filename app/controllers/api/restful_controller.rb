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

  API_DATE_PARAMETERS = %w(since until).freeze

  rescue_from CanCan::AccessDenied                    do |e| respond_with_standard_error e, 403 end
  rescue_from ActionController::UnpermittedParameters do |e| respond_with_standard_error e, 400 end

  def index
    instantiate_collection
    respond_with_collection
  end

  def create
    instantiate_resouce
    @event = service.create({resource_symbol => resource,
                            actor: current_user})
    respond_with_resource
  end

  def update
    load_resource
    service.update({resource_symbol => resource,
                    params: resource_params,
                    actor: current_user})
    respond_with_resource
  end

  def destroy
    load_resource
    service.destroy({resource_symbol => resource,
                     actor: current_user})
    render json: {success: 'success'}
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

  def load_and_authorize_motion
    if params[:motion_id]
      @motion = Motion.find(params[:motion_id])
    elsif params[:motion_key]
      @motion = Motion.find_by_key!(params[:motion_key])
    elsif params[:id]
      @motion = Motion.friendly.find(params[:id])
    end
    authorize! :show, @motion
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

  def collection=(obj)
    instance_variable_set :"@#{resource_name.pluralize}", obj
  end

  def instantiate_resouce
    self.resource = resource_class.new(resource_params)
  end

  def instantiate_collection(timeframe_collection: true, page_collection: true)
    collection = visible_records
    collection = yield collection                if block_given?
    collection = timeframe_collection collection if timeframe_collection
    collection = page_collection collection      if page_collection
    self.collection = collection.to_a
  end

  def timeframe_collection(collection)
    if resource_class.try(:has_timeframe?) && (params[:since] || params[:until])
      parse_date_parameters # I feel like Rails should do this for me..
      collection.within(params[:since], params[:until], params[:timeframe_for])
    else
      collection
    end
  end

  def parse_date_parameters
    API_DATE_PARAMETERS.each { |field| params[field] = DateTime.parse(params[field].to_s) if params[field] }
  end

  def page_collection(collection)
    collection.offset(params[:from]).limit(params[:per] || default_page_size)
  end

  def visible_records
    raise NotImplementedError.new
  end

  def default_page_size
    50
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
    render json: collection, root: serializer_root
  end

  def respond_with_resource
    if resource.errors.empty?
      if @event.is_a? Event
        render json: [@event], root: 'events', each_serializer: EventSerializer
      else
        render json: [resource], root: serializer_root
      end
    else
      respond_with_errors
    end
  end

  def respond_with_standard_error(error, status)
    render json: {exception: error.class.to_s}, root: false, status: status
  end

  def respond_with_errors
    render json: {errors: resource.errors.as_json()}, root: false, status: 422
  end

  def serializer_root
    controller_name
  end
end
