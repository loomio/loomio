class API::PollsController < API::RestfulController
  include UsesFullSerializer

  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def index
    instantiate_collection do |collection|
      collection = collection.where(discussion: @discussion) if load_and_authorize(:discussion, optional: true)
      collection = collection.where(author: current_user)    if params[:authored_only]
      collection = collection.send(params[:filter])          if Poll::FILTERS.include?(params[:filter].to_s)
      collection.order(:created_at)
    end
    respond_with_collection
  end

  def closed
    instantiate_collection { |collection| collection.where(discussion: load_and_authorize(:discussion)) }
    respond_with_collection
  end

  def close
    @event = service.close(poll: load_resource, actor: current_user)
    respond_with_resource
  end

  def publish
    @event = service.publish(poll: load_resource, params: publish_params, actor: current_user)
    respond_with_resource
  end

  def search
    instantiate_collection { |collection| filter_collection(collection) }
    respond_with_collection
  end

  private

  def publish_params
    params.slice(:community_id, :message)
  end

  def filter_collection(collection)
    collection = collection.where(discussion_id: @group.discussion_ids) if load_and_authorize(:group, optional: true)
    collection = collection.send(params[:filter])                       if Poll::FILTERS.include?(params[:filter].to_s)
    collection = collection.where(author: current_user)                 if params[:authored_only]
    collection = collection.search_for(params[:q])                      if params[:q].present?
    collection
  end

  def default_scope
    super.merge(my_stances_cache: Caches::Stance.new(user: current_participant, parents: resources_to_serialize))
  end

  def accessible_records
    Poll.where.any_of(
      current_user.polls,
      Poll.where(id: Queries::VisiblePolls.new(user: current_user).pluck(:id))
    )
  end
end
