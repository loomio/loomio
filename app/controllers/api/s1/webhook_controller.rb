class Api::S1::WebhookController < ActionController::API
  def create
    payload = Subscriptions::WebhookVerifier.new(request).verify!
    Subscriptions::ApplyUpdate.call(payload: payload, raw_body: request.raw_post)
    head :ok
  rescue Subscriptions::WebhookVerifier::InvalidSignature
    head :unauthorized
  rescue Subscriptions::ApplyUpdate::EventConflict
    head :conflict
  rescue Subscriptions::ApplyUpdate::InvalidUpdate, ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound
    head :unprocessable_entity
  end
end
