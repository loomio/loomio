Clients::Request = Struct.new(:method, :url, :params) do
  attr_accessor :callback

  def json
    @json ||= callback.call JSON.parse(response.body)
  end

  def perform!(options = {})
    result = if options[:is_success].call(response) then :success else :failure end
    self.callback = options[result]
  end

  def response
    @response ||= HTTParty.send(method, url, params)
  end
end
