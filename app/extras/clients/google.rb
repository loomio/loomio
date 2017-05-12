class Clients::Google < Clients::Base

  def fetch_access_token(code, uri)
    post "token",
      params: { code: code, redirect_uri: uri, grant_type: :authorization_code },
      options: { host: :"https://www.googleapis.com/oauth2/v4" }
  end

  def fetch_user_info
    get "people/me", options: { host: "https://people.googleapis.com/v1" }
  end

  def fetch_calendars
    get "users/me/calendarList", options: {
      success: ->(response) {
        response['items'].map { |item| { id: item['etag'], name: item['summary'] } }
      }
    }
  end

  def scope
    %w(email profile https://www.googleapis.com/auth/calendar).freeze
  end

  private

  def default_headers
    { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' }
  end

  def token_name
    :oauth_token
  end

  def default_host
    "https://www.googleapis.com/calendar/v3".freeze
  end
end
