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

  # workaround for 'csrf_detected' warning, https://github.com/mkdynamic/omniauth-facebook/issues/73
  option :provider_ignores_state, true

  # These are called after authentication has succeeded. If
  # possible, you should try to set the UID without making
  # additional calls (if the user id is returned with the token
  # or as a URI parameter). This may not be possible with all
  # providers.

  # We *need* a UID or else omniauth won't be able to persist name/email fields at registration
  uid{ raw_info['id'] || raw_info['result']['uid'] || fail("Could not find uid from #{raw_info.to_json}") }

  info do
    {
      # Support both normal OAuth2 and Drupal OAuth2
      :name => raw_info['name'] || raw_info['result']['field_full_name']['und']['item']['value'] || raw_info['result']['name'],
      :email => raw_info['email'] || raw_info['mail'] || raw_info['result']['mail']
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
