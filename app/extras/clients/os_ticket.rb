class Clients::OsTicket < Clients::Base
  def post_message(name, email, subject, message)
    post "api/tickets.json", params: {
      email: email,
      name: name,
      subject: subject,
      message: message
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
      'x-api-key' => ENV['OS_TICKET_API_KEY'],
      :Accept => 'application/json'
    )
  end

  def default_host
    ENV['OS_TICKET_HOST']
  end
end
