Clients::Request = Struct.new(:method, :url, :params) do
   attr_accessor :callback

   def json
     @json ||= callback.call JSON.parse(response.body)
   end

   def perform!(options = {})
     options[:is_success].call(response).tap do |is_success|
       self.callback = options[if is_success then :success else :failure end]
     end
   end

   def response
     @response ||= HTTParty.send(method, url, params)
   end
 end
