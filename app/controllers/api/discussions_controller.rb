class API::DiscussionsController < API::RestfulController

  def show
    respond_with_resource
  end

  def index
    @discussions = visible_records.where(group_id: params[:group_id]).order(:created_at)
    respond_with_collection
  end

  def create
    DiscussionService.start_discussion @discussion
    respond_with_resource
  end

  def update
    DiscussionService.edit_discussion current_user, permitted_params, @discussion
    respond_with_resource
  end

  private

  def visible_records
    if @group
      GroupDiscussionsViewer.for(user: current_user, group: @group)
    else
      Queries::VisibleDiscussions.new(user: current_user)
    end
  end

end
