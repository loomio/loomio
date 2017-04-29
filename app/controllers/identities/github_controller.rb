class Identities::GithubController < Identities::BaseController

  private

  def oauth_host
    "https://github.com/login/oauth/authorize"
  end

  def oauth_params
    { redirect_uri: redirect_uri, client_id: client.key, scope: client.scope.join(',') }
  end
end
