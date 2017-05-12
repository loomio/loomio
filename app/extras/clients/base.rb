class Clients::Base
  attr_reader :key

  def initialize(key: nil, secret: nil, token: nil)
    @key    = key
    @secret = secret
    @token  = token
  end

  def get(path, params = {}, success = default_success, failure = default_failure, is_success = default_is_success)
    perform(:get, path, { query: default_params.merge(params) }, success, failure, is_success)
  end

  def post(path, params = {}, success = default_success, failure = default_failure, is_success = default_is_success)
    perform(:post, path, { body: default_params.merge(params) }, success, failure, is_success)
  end

  def scope
    ""
  end

  private

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
    ->(response) {
      Airbrake.notify Exception.new(message: "Failed #{self.class.name.demodulize} api request", data: response)
      response
    }
  end

  def default_params
    { client_id: @key, client_secret: @secret, token_name => @token }.delete_if { |k,v| v.nil? }
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
