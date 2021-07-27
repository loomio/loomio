class Clients::Zammad < Clients::Base
  def post_message(name, email, subject, message)

    # this can fail if it already exists, and that's fine with me
    post "users", params: {
      firstname: name.split(' ').first,
      lastname: name.split(' ').drop(1).join(' '),
      email: email,
      roles: ["Customer"]
    }

    post "tickets", params: {
      title: subject,
      group: 'Users',
      customer_id: 'guess:'+email,
      note: message,
      article: {
        subject: subject,
        body: message,
        type: 'web',
        internal: false
      }
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
      'x-api-key' => ENV['ZAMMAD_TOKEN'],
      :Accept => 'application/json',
      :Authorization => "Token token=#{ENV['ZAMMAD_TOKEN']}"
    )
  end

  def default_host
    "https://#{ENV['ZAMMAD_HOST']}/api/v1"
  end
end
