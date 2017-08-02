class Clients::Intercom < Clients::Base

  def post_message(message)
    post "messages", params: {
      from: { type: :user, email: message.email, name: message.name },
      body: message.message
    }
  end

  def update_user(message)
    post "users", params: { email: message.email, name: message.name }
  end

  private

  def default_params
    {}
  end

  def default_headers
    super.merge(
      :Authorization => "Bearer #{@token}",
      :Accept => 'application/json'
    )
  end

  def default_host
    "https://api.intercom.io".freeze
  end
end
