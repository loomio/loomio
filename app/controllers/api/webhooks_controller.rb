class API::WebhooksController < API::RestfulController
  def create
    instantiate_resource
    create_action
    success_response
  end
end
