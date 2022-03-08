class API::V1::ChatbotsController < API::V1::RestfulController
  def index
    load_and_authorize(:group, :update)
    self.collection = Chatbot.where(group_id: @group.id)
    respond_with_collection
  end

  def test
    ChatbotService.publish_test!(params)
    head :ok
  end
end
