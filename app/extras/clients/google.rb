class Clients::Google < Clients::Base

  def fetch_access_token(code, redirect_uri)
    data = post("token", params: { code: code, redirect_uri: redirect_uri, grant_type: :authorization_code } ).json
    data['access_token']
  end

  def fetch_identity_params
    data = get("userinfo", options: { host: :"https://www.googleapis.com/oauth2/v2" }).json
    {
      uid: data['id'],
      name: data['name'],
      email: data['email'],
      logo: data['picture'],
      identity_type: 'google'
    }
  end

  def scope
    %w(email profile).freeze
  end

  private

  def default_headers
    { 'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8' }
  end

  def token_name
    :oauth_token
  end

  def default_host
    "https://www.googleapis.com/oauth2/v4".freeze
  end
end
