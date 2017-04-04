class API::PollsController < API::RestfulController
  include UsesFullSerializer

  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def index
    instantiate_collection { |collection| collection.where(discussion: load_and_authorize(:discussion)) }
    respond_with_collection
  end

  def close
    @event = service.close(poll: load_resource, actor: current_user)
    respond_with_resource
  end

  def search
    self.collection = page_collection poll_search.perform(search_filters)
    respond_with_collection
  end

  def search_results_count
    render json: poll_search.results_count
  end

  private

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
    Queries::VisiblePolls.new(user: current_user).joins(:discussion).order(created_at: :desc)
  end
end
