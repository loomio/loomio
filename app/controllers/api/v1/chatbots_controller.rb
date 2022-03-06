class API::V1::ChatbotsController < API::V1::RestfulController
  def index
    load_and_authorize(:group, :update)
    self.collection = Chatbot.where(group_id: @group.id)
    respond_with_collection
  end

  def test
    CHANNELS_REDIS_POOL.with do |client|
      data = params.slice(:server, :access_token, :channel)
      data.merge!(message: I18n.t('webhook.hello', group: params[:group_name]))
      client.publish("/chatbots/test", data.to_json)
    end
  end
end
