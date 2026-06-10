class Api::V1::ChatbotsController < Api::V1::RestfulController
  before_action :require_current_user, only: :check

  def index
    load_and_authorize(:group, :show_chatbots)
    self.collection = Chatbot.where(group_id: @group.id)
    respond_with_collection(scope: index_scope)
  end

  def check
    group = current_user.adminable_groups.find(params.require(:group_id))
    current_user.ability.authorize! :update, group
    ChatbotService.publish_test!(params)
    head :ok
  end

  def index_scope
    default_scope.merge({ current_user_is_admin: @group.admins.exists?(current_user.id)})
  end
end
