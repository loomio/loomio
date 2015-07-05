class Popolo::MotionsController < API::RestfulController

  private

  def resource_serializer
    Popolo::MotionSerializer
  end

end
