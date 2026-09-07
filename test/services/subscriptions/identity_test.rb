require "test_helper"

class Subscriptions::IdentityTest < ActiveSupport::TestCase
  setup do
    @installation_id_previous = ENV.delete("LOOMIO_INSTALLATION_ID")
    @api_token_previous = ENV.delete("LOOMIO_SUBSCRIPTIONS_API_TOKEN")
    @callback_secret_previous = ENV.delete("LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET")
  end

  teardown do
    restore_env("LOOMIO_INSTALLATION_ID", @installation_id_previous)
    restore_env("LOOMIO_SUBSCRIPTIONS_API_TOKEN", @api_token_previous)
    restore_env("LOOMIO_SUBSCRIPTIONS_CALLBACK_SECRET", @callback_secret_previous)
  end

  test "derives stable purpose-separated integration identity from the existing application secret" do
    installation_id = Subscriptions::Identity.installation_id
    integration_secret = Subscriptions::Identity.integration_secret

    assert_equal installation_id, Subscriptions::Identity.installation_id
    assert_equal integration_secret, Subscriptions::Identity.integration_secret
    assert_not_equal installation_id, integration_secret
    assert_equal "#{installation_id}.#{integration_secret}", Subscriptions::Identity.api_token
    assert_equal integration_secret, Subscriptions::Identity.webhook_secret
    assert_not_includes integration_secret, Rails.application.secret_key_base
  end

  test "defaults to the hosted subscription service" do
    previous = ENV.delete("LOOMIO_SUBSCRIPTIONS_URL")
    assert_equal "https://subscriptions.loomio.com", Subscriptions::Identity.service_url
  ensure
    restore_env("LOOMIO_SUBSCRIPTIONS_URL", previous)
  end

  test "registration proof is domain-separated and stable" do
    challenge = "challenge_test_abcdefghijklmnopqrstuvwxyz"
    proof = Subscriptions::Identity.registration_proof(challenge)

    assert_equal proof, Subscriptions::Identity.registration_proof(challenge)
    assert_not_equal proof, Subscriptions::Identity.registration_proof("#{challenge}_different")
  end

  private

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end
