class API::GroupsController < API::RestfulController
  include UsesFullSerializer
  after_action :track_visit, only: :show

  def token
    self.resource = load_and_authorize(:formal_group, :invite_people)
    respond_with_resource scope: {include_token: true}
  end

  def reset_token
    self.resource = load_and_authorize(:formal_group, :invite_people)
    resource.update(token: resource.class.generate_unique_secure_token)
    respond_with_resource scope: {include_token: true}
  end

  def show
    self.resource = load_and_authorize(:formal_group)
    respond_with_resource
  end

  def index
    instantiate_collection { |collection| collection.search_for(params[:q]).order(recent_activity_count: :desc) }
    respond_with_collection
  end

  def count_explore_results
    render json: { count: Queries::ExploreGroups.new.search_for(params[:q]).count }
  end

  def archive
    service.archive(group: load_resource, actor: current_user)
    respond_with_resource
  end

  def subgroups
    self.collection = load_and_authorize(:group).subgroups.select { |g| current_user.can? :show, g }
    respond_with_collection
  end

  def upload_photo
    ensure_photo_params
    service.update group: load_resource, actor: current_user, params: { params[:kind] => params[:file] }
    respond_with_resource
  end

  def export
    service.export(group: load_and_authorize(:group, :export), actor: current_user)
    render json: { success: :ok }
  end

  private
  def track_visit
    VisitService.record(group: resource, visit: current_visit, user: current_user)
  end

  def ensure_photo_params
    params.require(:file)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include? params.require(:kind)
  end

  def accessible_records
    Queries::ExploreGroups.new
  end

  def resource_class
    FormalGroup
  end

  # serialize out the parent with the group
  def resources_to_serialize
    Array(collection || [resource, resource&.parent].compact)
  end
end
