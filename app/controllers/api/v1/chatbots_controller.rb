class API::V1::ChatbotsController < API::V1::RestfulController
  def index
    load_and_authorize(:group, :show_chatbots)
    self.collection = Chatbot.where(group_id: @group.id)
    respond_with_collection(scope: index_scope)
  end

  def test
    ChatbotService.publish_test!(params)
    head :ok
  end

  def index_scope
    default_scope.merge({ current_user_is_admin: @group.admins.exists?(current_user.id)})
  end
end
