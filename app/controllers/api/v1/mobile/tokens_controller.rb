class Api::V1::Mobile::TokensController < ActionController::API
  rescue_from Mobile::AuthenticationService::Error, with: :render_mobile_error

  def create
    require_form_encoding!
    require_unique_form_parameters!
    pair = case params[:grant_type]
    when "authorization_code"
      Mobile::AuthenticationService.exchange_authorization_code!(
        code: required_parameter(:code),
        code_verifier: required_parameter(:code_verifier),
        client_id: required_parameter(:client_id),
        redirect_uri: required_parameter(:redirect_uri),
        device_name: params[:device_name]
      )
    when "refresh_token"
      Mobile::AuthenticationService.refresh!(
        refresh_token: required_parameter(:refresh_token),
        client_id: required_parameter(:client_id)
      )
    else
      raise Mobile::AuthenticationService::Error.new("unsupported_grant_type")
    end

    no_store!
    render json: Mobile::AuthenticationService.token_response(pair)
  end

  private

  def require_form_encoding!
    return if request.media_type == "application/x-www-form-urlencoded"

    raise Mobile::AuthenticationService::Error.new("invalid_request")
  end

  def require_unique_form_parameters!
    raise Mobile::AuthenticationService::Error.new("invalid_request") if request.raw_post.bytesize > 4_096

    names = URI.decode_www_form(request.raw_post).map(&:first)
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless names.uniq.length == names.length
  rescue ArgumentError
    raise Mobile::AuthenticationService::Error.new("invalid_request")
  end

  def required_parameter(name)
    value = params[name].to_s
    raise Mobile::AuthenticationService::Error.new("invalid_request") if value.blank? || value.bytesize > 512

    value
  end

  def no_store!
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
  end

  def render_mobile_error(error)
    no_store!
    render json: {
      error: error.code,
      error_description: I18n.t("mobile_auth.errors.#{error.code}", default: I18n.t("mobile_auth.errors.invalid_request"))
    }, status: error.status
  end
end
