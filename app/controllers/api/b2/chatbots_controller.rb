class Api::B2::ChatbotsController < Api::B2::BaseController
  def index
    self.collection = group.chatbots.order(:id)
    respond_with_collection scope: default_scope.merge(current_user_is_admin: true)
  end

  def create
    instantiate_resource
    resource.group = group
    self.resource = ChatbotService.create(chatbot: resource, actor: current_user)
    respond_with_resource scope: default_scope.merge(current_user_is_admin: true)
  end

  def update
    load_resource
    self.resource = ChatbotService.update(chatbot: resource, params: resource_params, actor: current_user)
    respond_with_resource scope: default_scope.merge(current_user_is_admin: true)
  end

  def destroy
    load_resource
    ChatbotService.destroy(chatbot: resource, actor: current_user)
    success_response
  end

  def check
    group
    ChatbotService.publish_test!(server: params.require(:server), kind: "slack_webhook")
    head :ok
  end

  private

  def group
    @group ||= current_user.adminable_groups.find(params.require(:group_id))
  end

  def load_resource
    self.resource = Chatbot.where(group_id: current_user.adminable_group_ids).find(params[:id])
  end
end
