class Clients::Helpy < Clients::Base
  def post_message(message)
    post "api/v1/tickets", params: {
      user_email: message.email,
      user_name: message.name,
      name: message.subject,
      body: message.message
    }
  end

  private

  def require_json_payload?
    true
  end

  def default_params
    {}
  end

  def default_headers
    super.merge(
      'X-Token' => ENV['HELPY_KEY'],
      :Accept => 'application/json'
    )
  end

  def default_host
    ENV['HELPY_HOST']
  end
end
