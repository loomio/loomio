FacebookClient = Struct.new(:key, :secret, :token) do
  VERSION = "v2.8"
  HOST = "https://graph.facebook.com/#{VERSION}"

  def get(path, params = {})
    yield response_for :get, path, { query: { access_token: token }.merge(params) }
  end

  def post(path, params = {})
    yield response_for :post, path, { body: { client_id: key, client_secret: secret }.merge(params) }
  end

  private

  def response_for(method, path, params)
    JSON.parse HTTParty.send(method, [HOST, path].join('/'), params.merge(headers: { 'Content-Type' => 'application/json' })).body
  end
end
