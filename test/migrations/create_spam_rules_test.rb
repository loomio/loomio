require 'test_helper'
require Rails.root.join('db/migrate/20261116000001_create_spam_rules')

class CreateSpamRulesTest < ActiveSupport::TestCase
  test 'the migration imports the installations exact regex once and rolls back cleanly' do
    original = ENV['SPAM_REGEX']
    pattern = "quo'ted|@(?:blocked\\.example|other\\.example)\\z"
    ENV['SPAM_REGEX'] = pattern
    connection = ActiveRecord::Base.connection
    original_path = connection.schema_search_path
    connection.execute('CREATE SCHEMA spam_rule_migration_test')
    connection.schema_search_path = 'spam_rule_migration_test,public'
    migration = CreateSpamRules.new
    migration.up
    rows = connection.select_all('SELECT kind, pattern FROM spam_rule_migration_test.spam_rules').to_a
    assert_equal [ { 'kind' => 'regex', 'pattern' => pattern } ], rows
    connection.execute("UPDATE spam_rule_migration_test.spam_rules SET pattern = 'edited' ")
    ENV['SPAM_REGEX'] = 'changed-after-import'
    assert_equal 'edited', connection.select_value('SELECT pattern FROM spam_rule_migration_test.spam_rules')
    migration.down
    assert_nil connection.select_value("SELECT to_regclass('spam_rule_migration_test.spam_rules')")
    assert_nil connection.select_value("SELECT to_regclass('spam_rule_migration_test.spam_rule_hits')")
  ensure
    original.nil? ? ENV.delete('SPAM_REGEX') : ENV['SPAM_REGEX'] = original
    if connection
      connection.schema_search_path = original_path if original_path
      connection.execute('DROP SCHEMA IF EXISTS spam_rule_migration_test CASCADE')
    end
  end
end
