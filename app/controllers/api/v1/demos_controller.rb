class API::V1::DemosController < API::V1::RestfulController
  before_action :require_current_user, only: [:clone]
  
  def index
    instantiate_collection
    respond_with_collection
  end

  def clone
    group = DemoService.take_demo(current_user)
    GenericWorker.perform_async('DemoService', 'refill_queue')
    self.collection = [group]
    respond_with_collection
  end

  def accessible_records
    Demo.all
  end
end
