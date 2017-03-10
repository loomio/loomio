Clients::Facebook = Struct.new(:key, :secret, :token) do

  def get(path, params = {})
    yield response_for :get, path, { query: { access_token: token }.merge(params) }
  end

  def post(path, params = {})
    yield response_for :post, path, { body: { client_id: key, client_secret: secret }.merge(params) }
  end

  private

  def host
    "https://graph.facebook.com/v2.8".freeze
  end

  def response_for(method, path, params)
    JSON.parse HTTParty.send(method, [host, path].join('/'), params.merge(headers: { 'Content-Type' => 'application/json' })).body
  end
end
