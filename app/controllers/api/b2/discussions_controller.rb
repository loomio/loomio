class Api::B2::DiscussionsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:discussion)
    respond_with_resource
  end

  def create
    instantiate_resource
    DiscussionService.create(actor: current_user, discussion: @discussion, params: params)
    respond_with_resource
  end

  def index
    instantiate_collection { |collection| collection.order_by_latest_activity }
    respond_with_collection
  end

  def accessible_records
    scope = Discussion.where(group_id: group.id)
    case params[:status]
    when 'closed' then scope.is_closed
    when 'all'    then scope.kept
    else               scope.is_open
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
