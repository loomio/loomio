require "test_helper"
require Rails.root.join("db/migrate/20260824000000_rotate_exposed_user_api_keys")

class RotateExposedUserApiKeysTest < ActiveSupport::TestCase
  test "migration invalidates every existing API key" do
    api_keys_before = User.pluck(:id, :api_key).to_h

    RotateExposedUserApiKeys.new.migrate(:up)

    api_keys_after = User.pluck(:id, :api_key).to_h
    assert_equal api_keys_before.keys.sort, api_keys_after.keys.sort
    assert_empty api_keys_before.values & api_keys_after.values
    assert_equal api_keys_after.length, api_keys_after.values.uniq.length
    assert api_keys_after.values.all?(&:present?)
  end

  test "migration cannot restore exposed API keys" do
    assert_raises ActiveRecord::IrreversibleMigration do
      RotateExposedUserApiKeys.new.migrate(:down)
    end
  end
end
