class Api::V1::LoginTokensController < Api::V1::RestfulController
  include RequiresLocalLogin

  def create
    unless TurnstileService.verify(params[:turnstile_token], remote_ip: request.remote_ip)
      render json: { errors: { turnstile: [ :'auth_form.turnstile_required' ] } }, status: 403
      return
    end

    user = User.find_by(email: params.require(:email))
    account_status = user&.email_status || :unused

    if account_status == :active
      save_detected_locale(user)
      service.create(actor: user, uri: referrer_uri)
    end

    response = if AppConfig.app_features[:reveal_email_account_status]
      { success: :ok, account_status: account_status }
    else
      { success: :ok }
    end
    render json: response
  end

  private

  def referrer_uri
    URI.parse(request.referrer.to_s)
  rescue URI::InvalidURIError
    nil
  end
end
