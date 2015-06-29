class API::Public::MotionsController < API::RestfulController

  private

  def respond_with_collection(scope: {})
    render json: collection, root: serializer_root, scope: scope, each_serializer: Popolo::MotionSerializer
  end

  def visible_records
    Motion.visible_to_public
  end

end
