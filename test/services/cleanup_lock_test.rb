require "test_helper"
require "timeout"

class CleanupLockTest < ActiveSupport::TestCase
  test "inactive-user deletion skips concurrent writers and leaves its transaction usable" do
    user = users(:orphan_user)
    assert_includes InactiveUserCleanupService.orphan_user_ids, user.id
    acquired = Queue.new
    release = Queue.new
    # Rails pins the fixture connection across threads. Use a genuinely
    # independent connection so this tests a concurrent writer, not that pin.
    config = ActiveRecord::Base.connection_db_config.configuration_hash
    connection = PG.connect(**config.slice(:host, :port, :password).merge(dbname: config[:database], user: config[:username]).compact)
    writer = Thread.new do
      connection.exec("SET lock_timeout = '3s'")
      connection.exec("BEGIN")
      connection.exec("LOCK TABLE users IN ROW EXCLUSIVE MODE")
      acquired << true
      release.pop
    rescue => error
      acquired << error
    ensure
      connection.exec("ROLLBACK")
      connection.close
    end

    result = Timeout.timeout(5) { acquired.pop }
    raise result if result.is_a?(Exception)
    InactiveUserCleanupService.destroy_orphan_users
    assert User.exists?(user.id)
  ensure
    release << true if release
    writer&.join(5)
  end
end
