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
    assert_equal "no-store", response.headers["Cache-Control"]
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
      challenge: "x" * 31
    }, as: :json

    assert_response :unauthorized
  end

  test "rejects a different registration phase even with the correct installation" do
    post "/api/s1/subscriptions/verify", params: {
      phase: "register", installation_id: Subscriptions::Identity.installation_id, challenge: "x" * 32
    }, as: :json

    assert_response :unauthorized
    assert_empty response.body
  end

  test "accepts challenge size boundaries and rejects an oversized challenge" do
    [32, 512, 513].each do |size|
      post "/api/s1/subscriptions/verify", params: {
        phase: "verify", installation_id: Subscriptions::Identity.installation_id, challenge: "x" * size
      }, as: :json

      assert_response(size <= 512 ? :success : :unauthorized)
      assert_equal "x" * size, response.parsed_body.fetch("challenge") if size <= 512
    end
  end

  test "accepts exactly the request size limit and rejects a larger body" do
    body = {
      phase: "verify", installation_id: Subscriptions::Identity.installation_id, challenge: "x" * 32
    }.to_json
    body += " " * (16.kilobytes - body.bytesize)

    post "/api/s1/subscriptions/verify", params: body + " ", headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :unauthorized
    post "/api/s1/subscriptions/verify", params: body, headers: { "CONTENT_TYPE" => "application/json" }
    assert_response :success
    assert_equal "x" * 32, response.parsed_body.fetch("challenge")
  end
end
