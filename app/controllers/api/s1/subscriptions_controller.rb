class Api::S1::SubscriptionsController < ActionController::API
  def verify
    raise KeyError if request.content_length.to_i > 16.kilobytes

    attributes = JSON.parse(request.raw_post)
    raise KeyError unless attributes.fetch("phase") == "verify"
    raise KeyError unless attributes.fetch("installation_id") == Subscriptions::Identity.installation_id

    challenge = attributes.fetch("challenge")
    raise KeyError unless challenge.is_a?(String) && challenge.bytesize.between?(32, 512)
    response.set_header("Cache-Control", "no-store")
    render json: {
      installation_id: Subscriptions::Identity.installation_id,
      challenge: challenge,
      proof: Subscriptions::Identity.registration_proof(challenge)
    }
  rescue JSON::ParserError, KeyError
    head :unauthorized
  end
end
