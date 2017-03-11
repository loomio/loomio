Clients::Slack = Struct.new(:key, :secret, :token) do

  def get(path, params = {})
    yield response_for :get, path, { query: { token: token, client_id: key, client_secret: secret }.merge(params) }
  end

  def post(path, params = {})
    yield response_for :post, path, params
  end

  private

  def host
    "https://slack.com/api".freeze
  end

  def response_for(method, path, params)
    JSON.parse HTTParty.send(method, [host, path].join('/'), params.merge(headers: { 'Content-Type' => 'application/json' })).body
  end
end
