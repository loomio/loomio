require 'test_helper'

class BootSiteTest < ActiveSupport::TestCase
  test "includes the group deletion grace period" do
    AppConfig.stub(:group_deletion_delay_days, 45) do
      assert_equal 45, Boot::Site.new.payload[:groupDeletionDelayDays]
    end
  end

  HELP_ENV_KEYS = %w[LOOMIO_HELP_TITLE LOOMIO_HELP_SUBTITLE LOOMIO_HELP_URL].freeze

  setup do
    @help_env = ENV.slice(*HELP_ENV_KEYS)
  end

  teardown do
    HELP_ENV_KEYS.each { |key| ENV.delete(key) }
    @help_env.each { |key, value| ENV[key] = value }
  end

  test "site config includes user manual overrides" do
    ENV['LOOMIO_HELP_TITLE'] = 'Operator guide'
    ENV['LOOMIO_HELP_SUBTITLE'] = 'How to use this service'
    ENV['LOOMIO_HELP_URL'] = 'https://docs.example.com/'

    assert_equal({
      title: 'Operator guide',
      subtitle: 'How to use this service',
      url: 'https://docs.example.com/'
    }, Boot::Site.new.payload[:userManual])
  end

  test "blank user manual overrides are omitted" do
    HELP_ENV_KEYS.each { |key| ENV[key] = ' ' }

    assert_equal({ title: nil, subtitle: nil, url: nil }, Boot::Site.new.payload[:userManual])
  end
end
