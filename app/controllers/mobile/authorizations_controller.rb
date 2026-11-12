class Mobile::AuthorizationsController < ApplicationController
  AUTHORIZATION_PARAMETER_LIMITS = {
    "response_type" => 16,
    "client_id" => 100,
    "redirect_uri" => 255,
    "code_challenge" => 128,
    "code_challenge_method" => 16,
    "state" => 256
  }.freeze
  REQUEST_TTL = 10.minutes

  def show
    authorization_request = validated_authorization_request
    return unless authorization_request

    session[:mobile_authorization_request] = authorization_request.merge("expires_at" => REQUEST_TTL.from_now.to_i)
    return unless authenticate_user!

    prevent_caching
    render Views::Mobile::Authorization.new(
      user: current_user,
      host: request.host,
      client: Mobile::Client.find(authorization_request.fetch("client_id"))
    )
  end

  def create
    return unless authenticate_user!

    authorization_request = session.delete(:mobile_authorization_request)
    return render plain: I18n.t("mobile_auth.errors.invalid_request"), status: :bad_request unless pending_request_valid?(authorization_request)

    if params[:decision] == "approve"
      code = Mobile::AuthenticationService.issue_authorization_code!(
        user: current_user,
        client: Mobile::Client.find(authorization_request.fetch("client_id")),
        redirect_uri: authorization_request.fetch("redirect_uri"),
        code_challenge: authorization_request.fetch("code_challenge")
      )
      redirect_to callback_url(authorization_request, code: code), allow_other_host: true
    else
      redirect_to callback_url(authorization_request, error: "access_denied"), allow_other_host: true
    end
  end

  private

  def validated_authorization_request
    pairs = URI.decode_www_form(request.query_string)
    values = pairs.group_by(&:first)
    valid_shape = AUTHORIZATION_PARAMETER_LIMITS.all? do |name, limit|
      values[name]&.one? && values[name].first.last.present? && values[name].first.last.bytesize <= limit
    end
    return invalid_authorization_request unless valid_shape

    request_params = AUTHORIZATION_PARAMETER_LIMITS.keys.index_with { |name| values.fetch(name).first.last }
    valid = request_params["response_type"] == "code" &&
      registered_redirect?(request_params) &&
      request_params["code_challenge_method"] == "S256" &&
      request_params["code_challenge"].match?(/\A[A-Za-z0-9_-]{43}\z/) &&
      request_params["state"].match?(/\A[A-Za-z0-9_-]{43}\z/)
    valid ? request_params : invalid_authorization_request
  rescue ArgumentError
    invalid_authorization_request
  end

  def invalid_authorization_request
    render plain: I18n.t("mobile_auth.errors.invalid_request"), status: :bad_request
    nil
  end

  def pending_request_valid?(request_data)
    request_data.is_a?(Hash) &&
      request_data["expires_at"].to_i > Time.current.to_i &&
      registered_redirect?(request_data)
  end

  # The callback can only go to the redirect registered for the requesting client.
  # This is checked before login and again on approval, because the session value
  # is the only record of where the code will be sent.
  def registered_redirect?(request_data)
    client = Mobile::Client.find(request_data["client_id"])
    client.present? && client.redirect_uri_valid?(request_data["redirect_uri"])
  end

  def callback_url(request_data, code: nil, error: nil)
    query = { state: request_data.fetch("state") }
    query[:code] = code if code
    query[:error] = error if error
    "#{request_data.fetch("redirect_uri")}?#{URI.encode_www_form(query)}"
  end
end
