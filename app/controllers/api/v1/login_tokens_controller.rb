class Api::V1::LoginTokensController < Api::V1::RestfulController
  def create
    unless TurnstileService.verify(params[:turnstile_token], remote_ip: request.remote_ip)
      render json: { errors: { turnstile: [:'auth_form.turnstile_required'] } }, status: 403
      return
    end
    if user = User.find_by(email: params.require(:email))
      save_detected_locale(user)
      service.create(actor: user, uri: URI::parse(request.referrer.to_s))
    end
    # Always return success to prevent account enumeration
    render json: { success: :ok }
  end
end
