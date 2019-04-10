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

  def get(path, params: {}, headers: {}, options: {})
    perform :get, path, params, headers, options.merge(params_field: :query)
  end

  def post(path, params: {}, headers: {}, options: {})
    perform :post, path, params, headers, options.merge(params_field: :body)
  end

  # make request for initial user information
  # overwrite if the API has a different endpoint to get a user
  def fetch_user_info
    get "me"
  end

  def scope_query_param
    scope.join(',')
  end

  def client_key_name
    :client_id
  end

  def scope
    []
  end

  private

  def perform(method, path, params, headers, options)
    options.reverse_merge!(
      host:       default_host,
      success:    default_success,
      failure:    default_failure,
      is_success: default_is_success
    )
    Clients::Request.new(method, [options[:host], path].compact.join('/'), {
      options[:params_field] => params_for(params),
      :"headers"             => headers_for(headers)
    }).tap { |request| request.perform!(options) }
  end

  def params_for(params = {})
    if require_json_payload?
      default_params.merge(params).to_json
    else
      default_params.merge(params)
    end
  end

  def headers_for(headers = {})
    default_headers.merge(headers)
  end

  def require_json_payload?
    false
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
      Rails.logger.info "Failed #{self.class.name.demodulize} api request. response: #{response} token: #{@token}"
      response
    }
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
    serializer = [
      "#{self.class.name.demodulize}::#{event.kind.classify}Serializer",
      "#{self.class.name.demodulize}::#{event.eventable.class}Serializer",
      "#{self.class.name.demodulize}::BaseSerializer"
    ].detect { |str| str.constantize rescue nil }.constantize
    serializer.new(event, root: false).as_json
  end

  def default_host
    raise NotImplementedError.new
  end
end
