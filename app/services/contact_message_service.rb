class ContactMessageService
  def self.deliver(email:, message:)
    data = { from: { type: "user", email: email }, body: message }
    headers = {'Authorization' => "Bearer #{ENV['INTERCOM_ACCESS_TOKEN']}",
               content_type: :json,
               accept: :json}

    RestClient.post("https://api.intercom.io/messages", data.to_json, headers)
  end
end
