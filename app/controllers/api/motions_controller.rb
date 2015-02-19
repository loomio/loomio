class API::MotionsController < API::RestfulController

  def close
    load_resource
    MotionService.close_by_user(@motion, current_user)
    respond_with_resource
  end

  private

  def visible_records
    load_and_authorize_discussion
    Queries::VisibleMotions.new(user: current_user)
                           .where(discussion: @discussion)
                           .order(:created_at)
  end

  def serializer_root 
    :proposals
  end

end
