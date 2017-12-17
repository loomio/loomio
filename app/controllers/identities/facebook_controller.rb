class Identities::FacebookController < Identities::BaseController
  before_action :allow_facebook_domains, only: :webview
  layout false

  def verify
    render text: params[:"hub.challenge"]
  end

  def webhook
    Clients::Facebook.instance.post_poll_button(recipient_id)
    head :ok
  end

  def webview
  end

  private

  def recipient_id
    params.dig(:entry, 0, :messaging, 0, :sender, :id)
  end

  def allow_facebook_domains
    response.headers['X-FRAME-OPTIONS'] = 'ALLOW_FROM https://www.messenger.com'
  end

  def complete_identity(identity)
    super
    identity.fetch_user_avatar
  end

  def oauth_host
    "https://www.facebook.com/v2.8/dialog/oauth"
  end
end
