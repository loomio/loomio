class Api::V1::LoginTokensController < Api::V1::RestfulController
  def create
    if user = User.find_by(email: params.require(:email))
      save_detected_locale(user)
      service.create(actor: user, uri: URI::parse(request.referrer.to_s))
    end
    # Always return success to prevent account enumeration
    render json: { success: :ok }
  end
end
