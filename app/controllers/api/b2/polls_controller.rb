class Api::B2::PollsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def create
    self.resource = PollService.create(params: resource_params, actor: current_user)
    PollService.invite(poll: resource, actor: current_user, params: params)
    respond_with_resource
  end

  def index
    instantiate_collection { |collection| collection.order(created_at: :desc) }
    respond_with_collection
  end

  def accessible_records
    scope = Poll.joins(:topic).where(topics: { group_id: group.id })
    case params[:status]
    when 'closed' then scope.closed
    when 'all'    then scope.kept
    else               scope.active
    end
  end

  private

  def group
    @group ||= Group.find(params[:group_id]).tap do |g|
      unless current_user.is_admin? || current_user.is_member_of?(g)
        raise CanCan::AccessDenied, "User is not a group member"
      end
    end
  end
end
