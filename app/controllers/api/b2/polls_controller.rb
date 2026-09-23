class Api::B2::PollsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def create
    self.resource = PollService.create(params: resource_params, actor: current_user)
    PollService.invite(poll: resource, actor: current_user, params: params) if resource.errors.empty?
    respond_with_resource
  end

  def update
    load_resource
    self.resource = PollService.update(poll: resource, params: resource_params, actor: current_user)
    respond_with_resource
  end

  def destroy
    load_resource
    PollService.discard(poll: resource, actor: current_user)
    respond_with_resource
  end

  def index
    instantiate_collection { |collection| collection.order(created_at: :desc) }
    respond_with_collection
  end

  def accessible_records
    scope = records_visible_in_group(Poll)
    case params[:status]
    when 'closed' then scope.closed
    when 'all'    then scope.kept
    else               scope.active
    end
  end
end
