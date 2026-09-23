require "test_helper"

class Api::S1::SubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "proves control using the installation-derived secret" do
    challenge = SecureRandom.urlsafe_base64(48)
    post "/api/s1/subscriptions/verify", params: {
      phase: "verify",
      installation_id: Subscriptions::Identity.installation_id,
      challenge: challenge
    }, as: :json

    assert_response :success
    assert_equal challenge, response.parsed_body.fetch("challenge")
    assert_equal Subscriptions::Identity.installation_id, response.parsed_body.fetch("installation_id")
    assert_equal Subscriptions::Identity.registration_proof(challenge), response.parsed_body.fetch("proof")
    assert_not response.parsed_body.key?("registration_secret")
  end

  test "does not answer a challenge for another installation" do
    post "/api/s1/subscriptions/verify", params: {
      phase: "verify",
      installation_id: "another-installation",
      challenge: SecureRandom.urlsafe_base64(48)
    }, as: :json

    assert_response :unauthorized
  end

  test "rejects an undersized challenge" do
    post "/api/s1/subscriptions/verify", params: {
      phase: "verify",
      installation_id: Subscriptions::Identity.installation_id,
      challenge: "short"
    }, as: :json

    assert_response :unauthorized
  end
end
