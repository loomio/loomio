require_relative "test_helper"

class RepositoryTest < RelayTest
  def test_persists_encrypted_registration_and_updates_its_credentials
    register
    row = @database.get_first_row("SELECT * FROM relay_registrations")
    refute_includes row.fetch("apns_token_ciphertext"), "a" * 64
    refute_includes row.fetch("delivery_key_ciphertext"), DELIVERY_KEY
    assert_equal registration, @repository.find_registration(ID)
    updated = registration.merge(host_origin: "https://second.example", delivery_key: "c" * 43)
    @repository.upsert_registration(**updated)
    assert_equal updated, @repository.find_registration(ID)
    assert_equal 0o600, File.stat(@path).mode & 0o777
    assert_equal "wal", @database.get_first_value("PRAGMA journal_mode")
  end

  def test_replaces_only_same_environment_and_token_and_cascades_old_state
    register
    production = registration(id: SecureRandom.uuid, environment: "production")
    other_token = registration(id: SecureRandom.uuid, token: "c" * 64)
    [production, other_token].each { |value| @repository.upsert_registration(**value) }
    @repository.claim_nonce(ID, "nonce", @time + 600)
    @repository.claim_event(ID, EVENT_ID)
    replacement = registration(id: SecureRandom.uuid)
    @repository.upsert_registration(**replacement)
    assert_nil @repository.find_registration(ID)
    [replacement, production, other_token].each { |value| assert_equal value, @repository.find_registration(value[:id]) }
    %w[relay_nonces relay_events].each { |table| assert_equal 0, @database.get_first_value("SELECT count(*) FROM #{table}") }
  end

  def test_failed_replacement_rolls_back_deletion
    register
    assert_raises(SQLite3::ConstraintException) do
      @repository.upsert_registration(**registration(id: SecureRandom.uuid).merge(host_origin: nil))
    end
    assert_equal registration, @repository.find_registration(ID)
  end

  def test_reclaims_failed_and_abandoned_events_but_never_delivered_events
    register
    assert @repository.claim_event(ID, EVENT_ID)
    refute @repository.claim_event(ID, EVENT_ID)
    @time += 120
    refute @repository.claim_event(ID, EVENT_ID)
    @time += 1
    assert @repository.claim_event(ID, EVENT_ID)
    @repository.finish_event(ID, EVENT_ID, delivered: false, error: "apns_unavailable")
    assert @repository.claim_event(ID, EVENT_ID)
    @repository.finish_event(ID, EVENT_ID, delivered: true)
    @time += 300
    refute @repository.claim_event(ID, EVENT_ID)
    assert_equal 3, @database.get_first_value("SELECT attempts FROM relay_events")
  end

  def test_separate_connections_atomically_claim_nonces_and_events
    register
    other_database = PushRelay::Database.open(@path)
    other = PushRelay::Repository.new(other_database, @key, clock: -> { @time })
    queue = Queue.new
    repositories = [@repository, other]
    threads = 12.times.map do |index|
      Thread.new do
        queue.pop
        repository = repositories[index % 2]
        [repository.claim_nonce(ID, "shared-nonce", @time + 600), repository.claim_event(ID, EVENT_ID)]
      end
    end
    12.times { queue << true }
    results = threads.map(&:value)
    assert_equal 1, results.count { |nonce, _event| nonce }
    assert_equal 1, results.count { |_nonce, event| event }
  ensure
    other&.close
  end

  def test_cleanup_expires_metadata_without_removing_registrations
    register
    @repository.claim_nonce(ID, "old", @time - 1)
    @repository.claim_nonce(ID, "future", @time + 60)
    @repository.claim_event(ID, EVENT_ID)
    @database.execute("UPDATE relay_events SET updated_at = ?", [@time - 30 * 86_400 - 1])
    @repository.cleanup
    assert_equal ["future"], @database.execute("SELECT nonce FROM relay_nonces").map { |row| row["nonce"] }
    assert_equal 0, @database.get_first_value("SELECT count(*) FROM relay_events")
    assert @repository.find_registration(ID)
  end

  def test_migrations_are_repeatable_and_failed_migrations_are_atomic
    register
    PushRelay::Database.migrate(@database)
    assert_equal registration, @repository.find_registration(ID)
    migrations = File.join(@directory, "migrations")
    FileUtils.mkdir_p(migrations)
    File.write(File.join(migrations, "002_bad.sql"), "CREATE TABLE partial (id TEXT); INVALID SQL;")
    assert_raises(SQLite3::SQLException) { PushRelay::Database.migrate(@database, directory: migrations) }
    assert_nil @database.get_first_value("SELECT name FROM sqlite_master WHERE name = 'partial'")
    assert_nil @database.get_first_value("SELECT filename FROM schema_migrations WHERE filename = '002_bad.sql'")
  end

  def test_backup_restores_committed_wal_and_encrypted_credentials
    register
    @repository.claim_nonce(ID, "retained-nonce", @time + 600)
    @repository.claim_event(ID, EVENT_ID)
    destination = File.join(@directory, "backup.sqlite3")
    PushRelay::Backup.create(@path, destination)
    restored_database = PushRelay::Database.open(destination)
    restored = PushRelay::Repository.new(restored_database, @key, clock: -> { @time })
    assert_equal registration, restored.find_registration(ID)
    refute restored.claim_nonce(ID, "retained-nonce", @time + 600)
    refute restored.claim_event(ID, EVENT_ID)
    assert_equal "ok", restored_database.get_first_value("PRAGMA integrity_check")
    assert_equal 0o600, File.stat(destination).mode & 0o777
    assert_raises(ArgumentError) { PushRelay::Backup.create(@path, @path) }
  ensure
    restored&.close
  end
end

class RepositoryTest
  def test_uuid_spellings_share_registration_and_delivery_identity
    @repository.upsert_registration(**registration(id: ID.upcase))
    assert_equal ID, @repository.find_registration(ID.upcase).fetch(:id)
    assert @repository.claim_event(ID.upcase, EVENT_ID.upcase)
    refute @repository.claim_event(ID, EVENT_ID)
    @repository.finish_event(ID.upcase, EVENT_ID.upcase, delivered: true)
    refute @repository.claim_event(ID, EVENT_ID)
    assert @repository.delete_registration(ID.upcase)
    assert_nil @repository.find_registration(ID)
  end
end
