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
    self.collection = PollSearch.new(current_user).perform(search_filters)
    respond_with_collection
  end

  private

  def search_filters
    Hash(params[:filters]).slice(:group_key, :status, :user, :query)
  end

  def default_scope
    super.merge my_stances_cache: MyStancesCache.new(participant: current_participant, polls: collection || Array(resource))
  end

  def accessible_records
    Queries::VisiblePolls.new(user: current_user).order(created_at: :desc)
  end
end
