class Api::B2::BaseController < Api::V1::SnorlaxBase
  skip_before_action :verify_authenticity_token
  before_action :authenticate_api_key!
  include ::LoadAndAuthorize

  def authenticate_api_key!
    raise CanCan::AccessDenied unless current_user
  end

  def current_user
    @current_user ||= User.active.find_by(api_key: bearer_token.presence || request.request_parameters[:api_key])
  end

  private

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

  def bearer_token
    request.authorization.to_s[/\ABearer (.+)\z/, 1].to_s
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
      resource_params = jarams
    end

    @permitted_params ||= PermittedParams.new(
      ActionController::Parameters.new(resource_name => resource_params)
    )
  end
end
