class Clients::Base
  attr_reader :key

  def self.instance
    new(
      key:    ENV["#{name.demodulize.upcase}_APP_KEY"],
      secret: ENV["#{name.demodulize.upcase}_APP_SECRET"]
    )
  end

  def initialize(key: nil, secret: nil, token: nil)
    @key    = key
    @secret = secret
    @token  = token
  end

  def get(path, params = {}, success = default_success, failure = default_failure, is_success = default_is_success)
    perform(:get, path, {
      host: params.delete(:host),
      query: default_params.merge(params),
      headers: default_headers
    }, success, failure, is_success)
  end

  def post(path, params = {}, success = default_success, failure = default_failure, is_success = default_is_success)
    perform(:post, path, {
      host: params.delete(:host),
      body: default_params.merge(params),
      headers: default_headers
    }, success, failure, is_success)
  end

  # make request for initial user information
  # overwrite if the API has a different endpoint to get a user
  def fetch_user_info
    get "me"
  end

  def scope_query_param
    scope.join(',')
  end

  private

  def scope
    []
  end

  def perform(method, path, params, success, failure, is_success)
    Clients::Response.new(method, [params.delete(:host) || host, path].join('/'), params, is_success).tap do |response|
      response.callback = if response.success? then success else failure end
    end
  end

  # determines whether the response should be deemed successful or not
  # we override this for things like requesting permissions from facebook,
  # where the response comes back with status 200, but the permissions contained
  # within aren't sufficient to operate the API
  def default_is_success
    ->(response) { response.success? }
  end

  def default_success
    ->(response) { response }
  end

  def default_failure
    ->(response) { puts response; response }
  end

  def default_params
    { client_id: @key, client_secret: @secret, token_name => @token }.delete_if { |k,v| v.nil? }
  end

  def default_headers
    { 'Content-Type' => 'application/json; charset=utf-8' }
  end

  def token_name
    :token
  end

  def post_content!(event)
    raise NotImplementedError.new
  end

  def serialized_event(event)
    begin
      "#{self.class.name.demodulize}::#{event.kind.classify}Serializer".constantize
    rescue NameError
      "#{self.class.name.demodulize}::BaseSerializer".constantize
    end.new(event, root: false).as_json
  end

  def host
    raise NotImplementedError.new
  end
end
