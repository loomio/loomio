Clients::Request = Struct.new(:method, :url, :params) do
  attr_accessor :callback, :success

  def json
    @json ||= callback.call JSON.parse(response.body)
  end

  def perform!(options = {})
    self.success  = options[:is_success].call(response)
    self.callback = options[success ? :success : :failure]
  end

  def response
    @response ||= connection.public_send(method) do |request|
      request.url(url)
      request.headers.update(params[:headers]) if params[:headers]
      request.params.update(params[:query]) if params[:query]
      request.body = params[:body] if params.key?(:body)
      request.options.timeout = params[:timeout] if params[:timeout]
      request.options.open_timeout = params[:timeout] if params[:timeout]
    end
  end

  private

  def connection
    Faraday.new(ssl: { verify: ssl_verify? }) do |faraday|
      faraday.request :url_encoded
      faraday.response :follow_redirects, limit: 3, clear_authorization_header: true
      faraday.adapter Faraday.default_adapter
    end
  end

  def ssl_verify?
    !ENV.key?('SSL_VERIFY_FALSE') && !ENV.key?('SSL_VERIFY_PEER_FALSE')
  end
end
