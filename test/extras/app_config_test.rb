require "test_helper"

class AppConfigTest < ActiveSupport::TestCase
  test "group deletion grace period is thirty days" do
    assert_equal 30, AppConfig.group_deletion_grace_days
  end

  setup do
    @chargify_api_key_previous = ENV.delete("CHARGIFY_API_KEY")
    @loomio_subscriptions_previous = ENV.delete("LOOMIO_SUBSCRIPTIONS")
  end

  teardown do
    restore_env("CHARGIFY_API_KEY", @chargify_api_key_previous)
    restore_env("LOOMIO_SUBSCRIPTIONS", @loomio_subscriptions_previous)
  end

  test "subscriptions are available when either billing integration is configured" do
    refute AppConfig.app_features.fetch(:subscriptions)
    refute AppConfig.app_features.fetch(:loomio_subscriptions)

    ENV["CHARGIFY_API_KEY"] = "chargify-key"
    assert AppConfig.app_features.fetch(:subscriptions)
    refute AppConfig.app_features.fetch(:loomio_subscriptions)

    ENV.delete("CHARGIFY_API_KEY")
    ENV["LOOMIO_SUBSCRIPTIONS"] = "1"
    assert AppConfig.app_features.fetch(:subscriptions)
    assert AppConfig.app_features.fetch(:loomio_subscriptions)
  end

  private

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end
