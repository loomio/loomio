class API::RestfulController < API::BaseController

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

  def load_and_authorize(model, action = :show)
    instance_variable_set :"@#{model}", ModelLocator.new(model, params).locate 
    authorize! action, instance_variable_get(:"@#{model}")
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
    collection = accessible_records
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

  API_DATE_PARAMETERS = %w(since until).freeze
  def parse_date_parameters
    API_DATE_PARAMETERS.each { |field| params[field] = DateTime.parse(params[field].to_s) if params[field] }
  end

  def page_collection(collection)
    collection.offset(params[:from]).limit(params[:per] || default_page_size)
  end

  def accessible_records
    if current_user
      visible_records
    else
      public_records
    end
  end

  def visible_records
    raise NotImplementedError.new
  end

  def public_records
    resource_class.visible_to_public.order(created_at: :desc)
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
    controller_name.singularize
  end

  def resource_class
    resource_name.camelize.constantize
  end

  def resource_plural
    controller_name
  end

  def resource_serializer
    "#{resource_name}_serializer".camelize.constantize
  end

  def service
    "#{resource_name}_service".camelize.constantize
  end

  def respond_with_collection(scope: {}, serializer: resource_serializer)
    render json: collection, root: serializer_root, scope: scope, each_serializer: serializer
  end

  def respond_with_resource(scope: {}, serializer: resource_serializer)
    if resource.errors.empty?
      if @event.is_a? Event
        render json: [@event], root: 'events', each_serializer: EventSerializer
      else
        render json: [resource], root: serializer_root, each_serializer: serializer
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
