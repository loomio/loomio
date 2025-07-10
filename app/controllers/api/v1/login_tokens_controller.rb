class Api::V1::LoginTokensController < Api::V1::RestfulController
  def create
    save_detected_locale(login_token_user)
    service.create(actor: login_token_user, uri: URI::parse(request.referrer.to_s))
    render json: { success: :ok }
  end

  private
  def login_token_user
    User.find_by!(email: params.require(:email))
  end
end
