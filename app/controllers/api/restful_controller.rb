class API::RestfulController < ActionController::Base
  include ::LocalesHelper
  include ::ProtectedFromForgery
  include ::LoadAndAuthorize
  include ::CurrentUserHelper
  before_filter :set_application_locale
  before_filter :set_paper_trail_whodunnit
  snorlax_used_rest!

  private

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
    Array(resource || collection)
  end
end
