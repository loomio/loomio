class API::RestfulController < ActionController::Base
  include ::LocalesHelper
  before_filter :set_application_locale
  before_filter :set_paper_trail_whodunnit
  snorlax_used_rest!

  include ::ProtectedFromForgery

  def create_action
    @event = service.create({resource_symbol => resource, actor: current_user})
  end

  def update_action
    @event = service.update({resource_symbol => resource, params: resource_params, actor: current_user})
  end

  def destroy_action
    service.destroy({resource_symbol => resource, actor: current_user})
  end

  private

  def current_user
    super || LoggedOutUser.new
  end

  def permitted_params
    @permitted_params ||= PermittedParams.new(params)
  end

  def load_and_authorize(model, action = :show, optional: false)
    return if optional && !(params[:"#{model}_id"] || params[:"#{model}_key"])
    instance_variable_set :"@#{model}", ModelLocator.new(model, params).locate
    authorize! action, instance_variable_get(:"@#{model}")
  end

  def service
    "#{resource_name}_service".camelize.constantize
  end

  def public_records
    resource_class.visible_to_public.order(created_at: :desc)
  end

  def respond_with_resource(scope: {}, serializer: resource_serializer, root: serializer_root)
    if resource.errors.empty?
      response_options = if @event.is_a?(Event)
        { resources: [@event], scope: scope, serializer: EventSerializer, root: :events }
      else
        { resources: [resource], scope: scope, serializer: serializer, root: root }
      end
      respond_with_collection response_options
    else
      respond_with_errors
    end
  end

end
