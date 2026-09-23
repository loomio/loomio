require "test_helper"
require Rails.root.join("db/migrate/20260820000000_remove_legacy_anonymous_stance_voting")

class RemoveLegacyAnonymousStanceVotingTest < ActiveSupport::TestCase
  test "migration refuses to run while an anonymous stance poll remains" do
    migration = RemoveLegacyAnonymousStanceVoting.new

    error = migration.stub(:select_value, 1) do
      migration.stub(:select_values, [123]) do
        assert_raises(ActiveRecord::MigrationError) { migration.migrate(:up) }
      end
    end

    assert_includes error.message, "Found 1 remaining poll"
    assert_includes error.message, "123"
  end

  test "migration refuses to run while an identified poll uses anonymous-ballot storage" do
    migration = RemoveLegacyAnonymousStanceVoting.new
    select_value = lambda do |sql|
      sql.include?("anonymous = FALSE") ? 1 : 0
    end
    select_values = lambda do |sql|
      sql.include?("anonymous = FALSE") ? [456] : []
    end

    error = migration.stub(:select_value, select_value) do
      migration.stub(:select_values, select_values) do
        assert_raises(ActiveRecord::MigrationError) { migration.migrate(:up) }
      end
    end

    assert_includes error.message, "Found 1 identified poll"
    assert_includes error.message, "456"
  end
end
