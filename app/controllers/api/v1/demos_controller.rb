class Api::V1::DemosController < Api::V1::RestfulController
  before_action :require_current_user, only: [:clone]

  def clone
    group = DemoService.take_demo(current_user)
    RefillDemoQueueWorker.perform_later
    self.collection = [group]
    respond_with_collection
  end
end
