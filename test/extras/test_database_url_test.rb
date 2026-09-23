require "test_helper"

class TestDatabaseUrlTest < ActiveSupport::TestCase
  test "Rails uses the database selected for this checkout" do
    database_name = TestDatabaseUrl.resolve(root: Rails.root).split("/").last

    assert_equal database_name, ActiveRecord::Base.connection_db_config.database
  end

  test "uses the shared database for the main checkout" do
    Dir.mktmpdir do |root|
      FileUtils.mkdir_p(File.join(root, ".git"))

      assert_equal "postgresql://localhost/loomio_test", TestDatabaseUrl.resolve(root: root)
    end
  end

  test "uses the parent directory to identify a standard Loomio worktree" do
    Dir.mktmpdir do |directory|
      root = File.join(directory, "Bronze-Harbor", "loomio")
      FileUtils.mkdir_p(root)
      FileUtils.touch(File.join(root, ".git"))

      assert_equal "postgresql://localhost/loomio_test_bronze_harbor", TestDatabaseUrl.resolve(root: root)
    end
  end

  test "uses the checkout directory for other linked worktree layouts" do
    Dir.mktmpdir do |directory|
      root = File.join(directory, "loomio-3.2-verify")
      FileUtils.mkdir_p(root)
      FileUtils.touch(File.join(root, ".git"))

      assert_equal "postgresql://localhost/loomio_test_loomio_3_2_verify", TestDatabaseUrl.resolve(root: root)
    end
  end
end
