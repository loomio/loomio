class Api::V1::Mobile::PushRegistrationsController < Api::V1::Mobile::BaseController
  before_action -> { require_mobile_scope!("notifications:manage") }

  def show
    registration = current_mobile_device.mobile_push_registration
    render json: { registered: registration.present? }
  end

  def test
    strict_json_body!(keys: [])
    registration = current_mobile_device.mobile_push_registration
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless registration

    Mobile::RelayService.send_test!(registration: registration)
    head :accepted
  end

  private

  def strict_json_body!(keys:)
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless request.media_type == "application/json"
    raise Mobile::AuthenticationService::Error.new("invalid_request") if request.raw_post.bytesize > 1_024

    body = JSON.parse(request.raw_post.presence || "{}")
    unless body.is_a?(Hash) && body.keys.sort == keys.sort
      raise Mobile::AuthenticationService::Error.new("invalid_request")
    end
    body
  rescue JSON::ParserError
    raise Mobile::AuthenticationService::Error.new("invalid_request")
  end
end
