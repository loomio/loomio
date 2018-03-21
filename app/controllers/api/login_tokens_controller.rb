class API::LoginTokensController < API::RestfulController
  def create
    save_detected_locale(login_token_user)
    service.create(actor: login_token_user, uri: URI::parse(request.referrer.to_s))
    render json: { code: current_user.login_tokens.last.code }
  end

  private
  def login_token_user
    User.verified_first.find_by!(email: params.require(:email))
  end
end
