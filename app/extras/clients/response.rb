Clients::Response = Struct.new(:method, :url, :params, :success) do
  attr_accessor :callback

  def json
    @json ||= callback.call JSON.parse(response.body)
  end

  def status
    @status ||= response.status
  end

  def response
    @response ||= HTTParty.send(method, url, params.merge(headers))
  end

  def success?
    success.call(response)
  end

  def headers
    { headers: { 'Content-Type' => 'application/json; charset=utf-8' } }
  end
end
