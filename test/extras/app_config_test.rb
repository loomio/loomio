require "test_helper"

class AppConfigTest < ActiveSupport::TestCase
  test "every manual time zone has a label in every supported language" do
    AppConfig.locales.fetch('supported').each do |locale|
      labels = YAML.load_file(Rails.root.join('config', 'locales', "timezones.#{locale}.yml")).fetch(locale).fetch('timezones').fetch('regions', {})

      assert_equal AppConfig.time_zones.sort, labels.keys.sort, "Time zone labels are incomplete for #{locale}"
      assert labels.values.all? { |label| label.is_a?(String) && label.present? }, "Time zone labels must be nonempty strings for #{locale}"
      labels.each do |identifier, label|
        assert_equal identifier.split('/').length, label.split(' / ').length, "Time zone labels must preserve every geographic path segment for #{identifier} in #{locale}"
      end
      client = YAML.load_file(Rails.root.join('config', 'locales', "client.#{locale}.yml")).fetch(locale)
      refute client.key?('timezones'), "Time zone labels must stay out of the client bundle for #{locale}"
    end
  end

  test "manual time zones cover every current clock rule" do
    now = Time.current
    # Compare transition dates as well as offsets: sharing today's offset alone
    # does not imply sharing seasonal rules. Ignore abbreviation-only changes.
    clock_rule = lambda do |zone|
      offset = zone.period_for_utc(now).utc_total_offset
      rule = [offset]
      zone.transitions_up_to(now + 20.years, now).each do |transition|
        next if transition.offset.utc_total_offset == offset

        offset = transition.offset.utc_total_offset
        rule << [transition.at.to_i, offset]
      end
      rule
    end
    selected_rules = AppConfig.time_zones.map { |identifier| clock_rule.call(TZInfo::Timezone.get(identifier)) }.to_set
    uncovered = TZInfo::Timezone.all_data_zones.reject { |zone| selected_rules.include?(clock_rule.call(zone)) }

    assert_empty uncovered.map(&:identifier), "Add a representative for each uncovered clock rule to config/time_zones.yml"
  end

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
