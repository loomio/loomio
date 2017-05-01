Clients::Response = Struct.new(:method, :url, :params, :success) do
  attr_accessor :callback

  def json
    @json ||= callback.call JSON.parse(response.body)
  end

  def status
    @status ||= response.status
  end

  def response
    @response ||= HTTParty.send(method, url, params)
  end

  # 'success' is a proc which accepts a response and returns true or false based
  # on whether that response from the API is satisfactory.
  # (this could be something like 'response.status is 200', or 'response.body[:ok] is true')
  def success?
    success.call(response)
  end
end
