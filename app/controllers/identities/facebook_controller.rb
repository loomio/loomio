class Identities::FacebookController < Identities::BaseController

  private

  def complete_identity(identity)
    identity.fetch_user_info
    identity.fetch_user_avatar
  end

  def oauth_host
    "https://www.facebook.com/v2.8/dialog/oauth"
  end
end
