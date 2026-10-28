class Api::User0::BaseController < Api::V1::SnorlaxBase
  # The user API accepts flat or explicitly nested payloads. Rails' inferred JSON wrapper
  # copies only model columns, dropping virtual fields such as group_id/options
  # when permitted_params selects the automatically generated resource object.
  wrap_parameters false

  include Api::User0::AuthenticatesApiKey
  include Api::User0::ResponseOptions
  include Api::User0::LegacyB2Fields
  include ::LoadAndAuthorize

  private

  # Bulk integrations can request larger pages without changing the default.
  def page_collection_bounded(collection, limit_max: 500, limit_default: default_page_size)
    super
  end

  # Group-scoped API indexes must use the same topic visibility rules as the
  # browser and direct record reads. Group visibility permits discovery, while
  # TopicQuery prevents a non-member from seeing private topics in that group.
  def records_visible_in_group(resource_class)
    group = Group.find(params[:group_id])
    raise CanCan::AccessDenied unless current_user.can?(:show, group)

    topicable_ids = TopicQuery.visible_to(
      user: current_user,
      group_ids: [ group.id ],
      or_subgroups: false
    ).where(topicable_type: resource_class.name).select(:topicable_id)

    resource_class.where(id: topicable_ids)
  end

  def permitted_params
    jarams = params.dup
    resource_params = jarams[resource_name]

    unless resource_params.respond_to?(:permit)
      jarams.delete(:api_key)
      jarams.delete(:format)
      jarams.delete(:controller)
      jarams.delete(:action)
      jarams.delete(:discussion)
      jarams.delete(:poll)
      jarams.delete(:id)
      # Comments use discussion_id to choose a parent in the controller; it
      # isn't an assignable Comment attribute.
      jarams.delete(:discussion_id) if resource_name == 'comment'
      resource_params = jarams
    end

    @permitted_params ||= PermittedParams.new(
      ActionController::Parameters.new(resource_name => resource_params)
    )
  end
end
