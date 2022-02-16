class API::V1::ChatbotsController < API::V1::RestfulController
  def index
    load_and_authorize(:group, :update)
    self.collection = Chatbot.where(group_id: @group.id)
    respond_with_collection
  end

  def test
    begin
      Clients::Matrix.new(
        server: params[:server],
        username: params[:username],
        password: params[:password],
        channel: params[:channel],
      ).post_test_message(params[:group_name])
      success_response
    rescue
      error_response
    end
  end
end
