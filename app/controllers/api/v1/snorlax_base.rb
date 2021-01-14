class API::V1::SnorlaxBase < ActionController::Base
  rescue_from(CanCan::AccessDenied)                    { |e| respond_with_standard_error e, 403 }
  rescue_from(ActionController::UnpermittedParameters) { |e| respond_with_standard_error e, 400 }
  rescue_from(ActionController::ParameterMissing)      { |e| respond_with_standard_error e, 400 }
  rescue_from(ActiveRecord::RecordNotFound)            { |e| respond_with_standard_error e, 404 }
  attr_accessor :collection_count

  def show
    respond_with_resource
  end

  def index
    instantiate_collection
    respond_with_collection
  end

  def create
    instantiate_resource
    create_action
    respond_with_resource
  end

  def create_action
    resource.save
  end

  def update
    load_resource
    update_action
    respond_with_resource
  end

  def update_action
    resource.update(resource_params)
  end

  def destroy
    load_resource
    destroy_action
    destroy_response
  end

  private

  def load_resource
    if resource_class.respond_to?(:friendly)
      self.resource = resource_class.friendly.find(params[:id])
    else
      self.resource = resource_class.find(params[:id])
    end
  end

  def create_action
    @event = service.create({resource_symbol => resource, actor: current_user})
  end

  def update_action
    @event = service.update({resource_symbol => resource, params: resource_params, actor: current_user})
  end

  def destroy_action
    service.destroy({resource_symbol => resource, actor: current_user})
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def service
    "#{resource_name}_service".camelize.constantize
  end

  def public_records
    resource_class.visible_to_public.order(created_at: :desc)
  end

  def respond_with_resource(scope: default_scope, serializer: serializer_class, root: serializer_root)
    if resource.errors.empty?
      respond_with_collection scope: scope, serializer: serializer, root: root
    else
      respond_with_errors
    end
  end

  def respond_ok
    render json: {}, status: 200
  end

  def respond_with_collection(scope: default_scope, serializer: serializer_class, root: serializer_root)
    render json: records_to_serialize, scope: scope, each_serializer: serializer, root: root, meta: meta.merge({total: collection_count})
  end

  def meta
    @meta || {}
  end

  def add_meta(key, value)
    @meta ||= {}
    @meta[key] = value
  end

  # prefer this
  def records_to_serialize
    if @event.is_a?(Event)
      Array(@event)
    else
      collection || Array(resource)
    end
  end

  def serializer_class
    record = records_to_serialize.first
    if record.nil?
      EventSerializer
    elsif record.is_a? Event
      EventSerializer
    else
      "#{record.class}Serializer".constantize
    end
  end

  def serializer_root
    record = records_to_serialize.first
    if record.nil?
      controller_name
    elsif record.is_a? Event
      'events'
    else
      record.class.to_s.underscore.pluralize
    end
  end

  def default_scope
    {
      cache: RecordCache.for_collection(records_to_serialize, current_user.id, exclude_types),
      current_user_id: current_user.id,
      exclude_types: exclude_types
    }
  end

  def exclude_types
    params[:exclude_types].to_s.split(' ')
  end

  # phase this out
  def events_to_serialize
    return [] unless @event.is_a?(Event)
    Array(@event)
  end

  # phase this out
  def resources_to_serialize
    collection || Array(resource)
  end


  def collection
    instance_variable_get :"@#{resource_name.pluralize}"
  end

  def resource
    instance_variable_get :"@#{resource_name}"
  end

  def resource=(value)
    instance_variable_set :"@#{resource_name}", value
  end

  def collection=(value)
    instance_variable_set :"@#{resource_name.pluralize}", value
  end

  def instantiate_resource
    self.resource = resource_class.new(self.class.filter_params(resource_class, resource_params))
  end

  def self.filter_params(resource_class, resource_params)
    newbie = resource_class.new
    out = {}.with_indifferent_access
    resource_params.each_pair do |k, v|
      out[k.to_sym] = v if newbie.respond_to?("#{k}=")
    end
    out
  end

  def instantiate_collection
    self.collection = accessible_records
    self.collection = yield collection if block_given?
    self.collection = timeframe_collection collection
    self.collection_count = collection.count
    self.collection = page_collection collection
    self.collection = order_collection collection
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
    %w(since until).each { |field| params[field] = DateTime.parse(params[field].to_s) if params[field] }
  end

  def page_collection(collection)
    collection.offset(params[:from].to_i).limit((params[:per] || default_page_size).to_i)
  end

  def order_collection(collection)
    if valid_orders.include?(params[:order])
      collection.order(params[:order])
    else
      collection
    end
  end

  def accessible_records
    if current_user.is_logged_in?
      visible_records
    else
      public_records
    end
  end

  def visible_records
    raise NotImplementedError.new
  end

  def valid_orders
    []
  end

  def public_records
    raise NotImplementedError.new
  end

  def default_page_size
    50
  end

  def destroy_action
    resource.destroy
  end

  def destroy_response
    success_response
  end

  def success_response
    render json: {success: 'success'}
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

  def respond_with_standard_error(error, status)
    render json: {exception: "#{error.class} #{error.to_s}"}, root: false, status: status
  end

  def respond_with_errors
    render json: {errors: resource.errors.as_json}, root: false, status: 422
  end
end
