class Api::GroupsController < Api::RestfulController

  def index
    instantiate_collection { |collection| collection.search_for params[:q] }
    respond_with_collection
  end

  def count_explore_results
    render json: { count: Queries::ExploreGroups.new.search_for(params[:q]).count }
  end

  def create
    instantiate_resource
    create_action
    respond_with_resource(scope: {current_user: current_user})
  end

  def archive
    GroupService.archive(group: fetch_resource, actor: current_user)
    respond_with_resource
  end

  def subgroups
    self.collection = fetch_and_authorize(:group).subgroups.select { |g| can? :show, g }
    respond_with_collection
  end

  def use_gift_subscription
    if SubscriptionService.available?
      SubscriptionService.new(fetch_resource, current_user).start_gift!
      respond_with_resource
    else
      respond_with_standard_error ActionController::BadRequest, 400
    end
  end

  def upload_photo
    ensure_photo_params
    service.update group: fetch_resource, actor: current_user, params: { params[:kind] => params[:file] }
    respond_with_resource
  end

  private

  def ensure_photo_params
    params.require(:file)
    raise ActionController::UnpermittedParameters.new([:kind]) unless ['logo', 'cover_photo'].include? params.require(:kind)
  end

  def accessible_records
    Queries::ExploreGroups.new
  end

  # serialize out the parent with the group
  def resources_to_serialize
    Array(collection || [resource, resource&.parent].compact)
  end
end
