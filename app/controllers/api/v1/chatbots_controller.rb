class Api::V1::ChatbotsController < Api::V1::RestfulController
  def index
    load_and_authorize(:group, :show_chatbots)
    self.collection = Chatbot.where(group_id: @group.id)
    respond_with_collection(scope: index_scope)
  end

  def check
    ChatbotService.publish_test!(params)
    head :ok
  end

  def create_notion_database
    client = Clients::Notion.new(access_token: params[:access_token])
    response = client.create_database(
      page_id: params[:page_id],
      title: params[:title] || "Loomio Decisions"
    )

    if response.success?
      render json: { database_id: response.parsed_response["id"] }
    else
      render json: { error: response.parsed_response&.dig("message") || "Failed to create database" },
             status: :unprocessable_entity
    end
  end

  def index_scope
    default_scope.merge({ current_user_is_admin: @group.admins.exists?(current_user.id)})
  end
end
