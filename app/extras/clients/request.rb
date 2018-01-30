Clients::Request = Struct.new(:method, :url, :params) do
  include HTTParty
  debug_output $stdout

  attr_accessor :callback, :success

  def json
    @json ||= callback.call JSON.parse(response.body)
  end

  def perform!(options = {})
    self.success  = options[:is_success].call(response)
    self.callback = options[success ? :success : :failure]
  end

  def response
    @response ||= self.class.send(method, url, params)
  end
end
