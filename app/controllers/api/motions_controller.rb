class API::MotionsController < API::RestfulController
  load_resource only: [:create, :update]

  def index
    @motions = visible_records.where(discussion: @discussion).order(:created_at)
    respond_with_collection
  end

  def create
    MotionService.create motion: @motion, actor: current_user
    respond_with_resource
  end

  def update
    MotionService.update motion: @motion, params: motion_params, actor: current_user
    respond_with_resource
  end

  private
  def motion_params
    params.require(:motion).permit([:name, :description, :discussion_id, :closing_at, :outcome])
  end

  def visible_records
    Queries::VisibleMotions.new(user: current_user)
  end

end
