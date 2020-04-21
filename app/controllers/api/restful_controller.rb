class API::RestfulController < API::SnorlaxBase
  include ::ForceSslHelper
  include ::LocalesHelper
  include ::ProtectedFromForgery
  include ::LoadAndAuthorize
  include ::CurrentUserHelper
  include ::SentryRavenHelper
  include ::PendingActionsHelper

  before_action :handle_pending_actions
  around_action :use_preferred_locale       # LocalesHelper
  before_action :set_paper_trail_whodunnit  # gem 'paper_trail'
  before_action :set_raven_context          # SentryRavenHelper
  after_action :associate_user_to_visit

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

  def respond_with_resource(scope: default_scope, serializer: resource_serializer, root: serializer_root)
    if resource.errors.empty?
      respond_with_collection scope: scope, serializer: serializer, root: root
    else
      respond_with_errors
    end
  end

  def respond_ok
    render json: {}, status: 200
  end

  def respond_with_collection(scope: default_scope, serializer: resource_serializer, root: serializer_root)
    if events_to_serialize.any?
      render json: EventCollection.new(events_to_serialize).serialize!(scope)
    else
      render json: resources_to_serialize, scope: scope, each_serializer: serializer, root: root
    end
  end

  def events_to_serialize
    return [] unless @event.is_a?(Event)
    Array(@event)
  end

  def resources_to_serialize
    Array(collection || resource)
  end

  def default_scope
    { current_user: current_user, exclude_types: params[:exclude_types].to_s.split(' ') }
  end

end
