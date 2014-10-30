class API::MotionsController < API::RestfulController
  
  def index
    @motions = visible_records.where(discussion: @discussion).order(:created_at)
    respond_with_collection
  end

  def create
    MotionService.create @motion
    respond_with_resource
  end

  def update
    MotionService.update_motion motion: @motion, params: permitted_params, user: current_user
    respond_with_resource
  end

  private

  def visible_records
    Queries::VisibleMotions.new(user: current_user)
  end

end
