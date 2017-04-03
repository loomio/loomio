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
    instantiate_collection { |collection| filter_collection(collection) }
    respond_with_collection
  end

  private

  def filter_collection(collection)
    collection = collection.where(discussion_id: @group.discussion_ids) if load_and_authorize(:group, optional: true)
    collection = collection.send(params[:filter])                       if Poll::FILTERS.include?(params[:filter].to_s)
    collection = collection.where(author: current_user)                 if params[:authored_only]
    collection = collection.search_for(params[:q])                      if params[:q].present?
    collection
  end

  def default_scope
    super.merge my_stances_cache: MyStancesCache.new(participant: current_participant, polls: collection || Array(resource))
  end

  def accessible_records
    Queries::VisiblePolls.new(user: current_user).order(created_at: :desc)
  end
end
