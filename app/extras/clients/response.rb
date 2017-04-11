Clients::Response = Struct.new(:method, :url, :params) do
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
    response.success?
  end

  def headers
    { headers: { 'Content-Type' => 'application/json; charset=utf-8' } }
  end
end
