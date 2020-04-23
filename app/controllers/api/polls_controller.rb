class API::PollsController < API::RestfulController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
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

  def add_options
    @event = service.add_options(poll: load_resource, params: params.slice(:poll_option_names), actor: current_user)
    respond_with_resource
  end

  def toggle_subscription
    service.toggle_subscription(poll: load_resource, actor: current_user)
    respond_with_resource
  end

  private

  def default_scope
    super.merge(current_user: current_user,
                my_stances_cache: Caches::Stance.new(user: current_user, parents: resources_to_serialize))
  end

  def accessible_records
    PollQuery.visible_to(user: current_user)
  end
end
