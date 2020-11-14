class API::GroupsController < API::RestfulController
  def token
    self.resource = load_and_authorize(:group, :invite_people)
    respond_with_resource scope: {include_token: true, exclude_types: ['membership', 'user']}
  end

  def suggest_handle
    render json: { handle: service.suggest_handle(name: params[:name], parent_handle: params[:parent_handle])  }
  end

  def reset_token
    self.resource = load_and_authorize(:group, :invite_people)
    resource.update(token: resource.class.generate_unique_secure_token)
    respond_with_resource scope: {include_token: true, exclude_types: ['membership', 'user']}
  end

  def show
    self.resource = load_and_authorize(:group)
    accept_pending_membership
    cache = RecordCache.for_groups(Array(resource.id), current_user.id)
    respond_with_resource(scope: {cache: cache})
  end

  def index
    order_attributes = ['created_at', 'memberships_count']
    order = (order_attributes.include? params[:order])? "groups.#{params[:order]} DESC" : 'groups.memberships_count DESC'
    instantiate_collection { |collection| collection.search_for(params[:q]).order(order) }
    respond_with_collection
  end

  def count_explore_results
    render json: { count: Queries::ExploreGroups.new.search_for(params[:q]).count }
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
  def ensure_photo_params
    params.require(:file)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include? params.require(:kind)
  end

  def accessible_records
    Queries::ExploreGroups.new
  end

  def resource_class
    Group
  end

  # serialize out the parent with the group
  def resources_to_serialize
    Array(collection || [resource, resource&.parent].compact)
  end
end
