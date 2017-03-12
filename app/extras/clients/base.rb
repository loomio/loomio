class Clients::Base
  def initialize(key: nil, secret: nil, token: nil)
    @key    = key
    @secret = secret
    @token  = token
  end

  def get(path, params = {})
    yield response_for :get, path, { query: default_params.merge(params) }
  end

  def post(path, params = {})
    yield response_for :post, path, { body: default_params.merge(params) }
  end

  private

  def default_params
    { client_id: @key, client_secret: @secret, token_name => @token }.delete_if { |k,v| v.nil? }
  end

  def token_name
    :token
  end

  def host
    raise NotImplementedError.new
  end

  def response_for(method, path, params)
    JSON.parse HTTParty.send(method, [host, path].join('/'), params.merge(headers: { 'Content-Type' => 'application/json' })).body
  end
end
