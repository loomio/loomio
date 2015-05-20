require 'omniauth-oauth2'

class CustomOauth2 < OmniAuth::Strategies::OAuth2
  # Give your strategy a name.
  option :name, "custom_oauth2"

  # This is where you pass the options you would pass when
  # initializing your consumer from the OAuth gem.
  option :client_options, {
    site: 'https://example.com',
    authorize_url: '/oauth2/authorize',
    token_url: '/oauth2/token'
  }

  option :info_url, "user"
  option :use_post, false

  # These are called after authentication has succeeded. If
  # possible, you should try to set the UID without making
  # additional calls (if the user id is returned with the token
  # or as a URI parameter). This may not be possible with all
  # providers.
  uid{ raw_info['id'] }

  info do
    {
      :name => raw_info['name'],
      :email => raw_info['email']
    }
  end

  extra do
    {
      'raw_info' => raw_info
    }
  end

  def raw_info
    access_token.options[:mode] = :query
    if options[:use_post]
      @raw_info ||= access_token.post(options[:info_url]).parsed
    else
      @raw_info ||= access_token.get(options[:info_url]).parsed
    end
  end
end
