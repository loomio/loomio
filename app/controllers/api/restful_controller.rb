class API::RestfulController < API::SnorlaxBase
  include ::ForceSslHelper
  include ::LocalesHelper
  include ::ProtectedFromForgery
  include ::LoadAndAuthorize
  include ::CurrentUserHelper
  include ::SentryHelper
  include ::PendingActionsHelper

  before_action :handle_pending_actions
  around_action :use_preferred_locale       # LocalesHelper
  before_action :set_paper_trail_whodunnit  # gem 'paper_trail'
  before_action :set_sentry_context          # SentryHelper
  before_action :deny_spam_users            # CurrentUserHelper
  after_action :associate_user_to_visit

  protected

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
end
