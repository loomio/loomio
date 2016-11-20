class Popolo::MotionsController < API::MotionsController

  private

  def accessible_records
    Queries::VisibleMotions.new(user: current_user, groups: current_user.groups)
  end

  def resource_serializer
    Popolo::MotionSerializer
  end

  def serializer_root
    :motions
  end

end
