class Api::V1::DemosController < Api::V1::RestfulController
  before_action :require_current_user

  def clone
    group = DemoService.take_demo(current_user)
    GenericWorker.perform_async('DemoService', 'refill_queue')
    self.collection = [group]
    respond_with_collection
  end
end
