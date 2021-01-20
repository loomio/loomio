class API::V1::WebhooksController < API::V1::RestfulController
  def index
    load_and_authorize(:group, :update)
    self.collection = @group.webhooks
    respond_with_collection
  end
end
