class API::LoginTokensController < API::RestfulController
  def create
    service.create(actor: User.find_by(email: params.require(:email)))
    head :ok
  end
end
