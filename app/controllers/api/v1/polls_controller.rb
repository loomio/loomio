class API::V1::PollsController < API::V1::RestfulController
  def show
    self.resource = load_and_authorize(:poll)
    accept_pending_membership
    respond_with_resource
  end

  def remind
    event = service.remind(poll: load_and_authorize(:poll), actor: current_user, params: resource_params)
    render json: {count: event.recipient_user_ids.count}
  end

  def index
    instantiate_collection do |collection|
      PollQuery.filter(chain: collection, params: params).order(created_at: :desc)
    end
    respond_with_collection
  end

  def close
    @event = service.close(poll: load_resource, actor: current_user)
    respond_with_resource
  end

  def reopen
    @event = service.reopen(poll: load_resource, params: resource_params, actor: current_user)
    respond_with_resource
  end

  def discard
    load_resource
    @event = service.discard(poll: resource, actor: current_user)
    respond_with_resource
  end

  def add_to_thread
    @event = service.add_to_thread(poll: load_resource, params: params, actor: current_user)
    respond_with_resource
  end

  def voters
    load_and_authorize(:poll)
    if !@poll.anonymous
      self.collection = User.where(id: @poll.voter_ids)
    else
      self.collection = User.none
    end
      cache = RecordCache.for_collection(collection, current_user.id, exclude_types)
      respond_with_collection serializer: AuthorSerializer, root: :users, scope: {cache: cache, exclude_types: exclude_types}
  end

  private
  def create_action
    @event = service.create(**{resource_symbol => resource, actor: current_user, params: resource_params})
  end

  def accessible_records
    PollQuery.visible_to(user: current_user, show_public: false)
  end
end
