class Api::V1::DemosController < Api::V1::RestfulController
  before_action :require_current_user, only: [:clone]

  def clone
    unless ThrottleService.can?(key: 'DemoClones', id: current_user.id, max: 3, per: 'day')
      render json: { error: 'Rate limit exceeded' }, status: 429
      return
    end

    group = DemoService.take_demo(current_user)
    RefillDemoQueueWorker.perform_later
    self.collection = [group]
    respond_with_collection
  end
end
