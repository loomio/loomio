class API::LoginTokensController < API::RestfulController
  def create
    service.create(actor: login_token_user, uri: URI::parse(request.referrer.to_s))
    head :ok
  end

  private

  def login_token_user
    User.find_by!(email: params.require(:email))
  end
end
