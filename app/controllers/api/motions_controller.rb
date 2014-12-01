class API::MotionsController < API::RestfulController

  def index
    load_and_authorize_discussion
    @motions = visible_records.where(discussion: @discussion).order(:created_at)
    respond_with_collection
  end

  def close
    load_resource
    MotionService.close_by_user(@motion, current_user)
    respond_with_resource
  end

  private

  def visible_records
    Queries::VisibleMotions.new(user: current_user)
  end

  def serializer_root 
    :proposals
  end

end
