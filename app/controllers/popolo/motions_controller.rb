class Popolo::MotionsController < Api::MotionsController

  private

  def resource_serializer
    Popolo::MotionSerializer
  end

  def serializer_root
    :motions
  end

end
