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
    self.collection = page_collection poll_search.perform(search_filters)
    respond_with_collection
  end

  def search_results_count
    render json: poll_search.perform(search_filters).count
  end

  private

  def publish_params
    params.slice(:community_id, :message)
  end

  def poll_search
    PollSearch.new(current_user)
  end

  def search_filters
    params.slice(:group_key, :status, :user, :query)
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
