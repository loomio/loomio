require "test_helper"

class AppConfigTest < ActiveSupport::TestCase
  test "group deletion grace period is ninety days" do
    assert_equal 90, AppConfig.group_deletion_delay_days
  end

  test "group deletion grace period can be configured" do
    ENV["GROUP_DELETION_DELAY_DAYS"] = "45"
    assert_equal 45, AppConfig.group_deletion_delay_days
  end

  setup do
    @chargify_api_key_previous = ENV.delete("CHARGIFY_API_KEY")
    @loomio_subscriptions_previous = ENV.delete("LOOMIO_SUBSCRIPTIONS")
    @group_deletion_delay_days_previous = ENV.delete("GROUP_DELETION_DELAY_DAYS")
    @default_onboarding_group_id_previous = ENV.delete("DEFAULT_ONBOARDING_GROUP_ID")
    @disable_edit_user_profile_previous = ENV.delete("LOOMIO_DISABLE_EDIT_USER_PROFILE")
    @sso_force_user_attrs_previous = ENV.delete("LOOMIO_SSO_FORCE_USER_ATTRS")
    @disable_local_login_previous = ENV.delete("FEATURES_DISABLE_LOCAL_LOGIN")
    @disable_email_login_previous = ENV.delete("FEATURES_DISABLE_EMAIL_LOGIN")
    @reveal_email_account_status_previous = ENV.delete("FEATURES_REVEAL_EMAIL_ACCOUNT_STATUS")
  end

  teardown do
    restore_env("CHARGIFY_API_KEY", @chargify_api_key_previous)
    restore_env("LOOMIO_SUBSCRIPTIONS", @loomio_subscriptions_previous)
    restore_env("GROUP_DELETION_DELAY_DAYS", @group_deletion_delay_days_previous)
    restore_env("DEFAULT_ONBOARDING_GROUP_ID", @default_onboarding_group_id_previous)
    restore_env("LOOMIO_DISABLE_EDIT_USER_PROFILE", @disable_edit_user_profile_previous)
    restore_env("LOOMIO_SSO_FORCE_USER_ATTRS", @sso_force_user_attrs_previous)
    restore_env("FEATURES_DISABLE_LOCAL_LOGIN", @disable_local_login_previous)
    restore_env("FEATURES_DISABLE_EMAIL_LOGIN", @disable_email_login_previous)
    restore_env("FEATURES_REVEAL_EMAIL_ACCOUNT_STATUS", @reveal_email_account_status_previous)
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

  test "SSO profile edit restrictions are presence-based" do
    refute AppConfig.app_features.fetch(:sso_disable_edit_profile)

    ENV["LOOMIO_DISABLE_EDIT_USER_PROFILE"] = "0"

    assert AppConfig.app_features.fetch(:sso_disable_edit_profile)
  end

  test "local login restrictions are presence-based and retain the email-login alias" do
    assert AppConfig.local_login_enabled?
    assert AppConfig.app_features.fetch(:local_login)
    refute AppConfig.app_features.key?(:email_login)

    ENV["FEATURES_DISABLE_LOCAL_LOGIN"] = "0"
    refute AppConfig.local_login_enabled?
    refute AppConfig.app_features.fetch(:local_login)

    ENV.delete("FEATURES_DISABLE_LOCAL_LOGIN")
    ENV["FEATURES_DISABLE_EMAIL_LOGIN"] = "0"
    refute AppConfig.local_login_enabled?
  end

  test "revealing email account status is presence-based and disabled by default" do
    refute AppConfig.app_features.fetch(:reveal_email_account_status)

    ENV["FEATURES_REVEAL_EMAIL_ACCOUNT_STATUS"] = "0"

    assert AppConfig.app_features.fetch(:reveal_email_account_status)
  end

  test "default onboarding group id can be configured" do
    assert_nil AppConfig.default_onboarding_group_id

    ENV["DEFAULT_ONBOARDING_GROUP_ID"] = "123"

    assert_equal 123, AppConfig.default_onboarding_group_id

    ENV["DEFAULT_ONBOARDING_GROUP_ID"] = ""

    assert_nil AppConfig.default_onboarding_group_id
  end

  private

  def restore_env(name, value)
    value.nil? ? ENV.delete(name) : ENV[name] = value
  end
end
