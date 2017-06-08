class Identities::GoogleController < Identities::BaseController

  private

  def oauth_url
    super.gsub("%2B", "+")
  end

  def oauth_host
    "https://accounts.google.com/o/oauth2/v2/auth"
  end

  def oauth_params
    super.merge(response_type: :code, scope: client.scope.join('+'))
  end
end
