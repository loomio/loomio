class Identities::GithubController < Identities::BaseController

  private

  def complete_identity(identity)
    identity.fetch_user_info
  end

  def oauth_url
    "https://github.com/login/oauth/authorize"
  end

  def oauth_params
    super.merge(client_id: client.key)
  end
end
