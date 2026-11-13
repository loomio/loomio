require "sqlite3"
require "fileutils"
require "securerandom"

module PushRelay
  module Backup
    module_function

    # SQLite's backup API includes committed WAL pages in a consistent standalone
    # database. Copying the live .sqlite3 file alone would lose those pages.
    def create(source_path, destination_path)
      raise ArgumentError, "backup destination must differ from the live database" if File.expand_path(source_path) == File.expand_path(destination_path)
      FileUtils.mkdir_p(File.dirname(destination_path), mode: 0o700)
      temporary = "#{destination_path}.#{SecureRandom.hex(8)}.tmp"
      source = SQLite3::Database.new(source_path, readonly: true)
      destination = SQLite3::Database.new(temporary)
      source.busy_timeout = destination.busy_timeout = 5_000
      backup = SQLite3::Backup.new(destination, "main", source, "main")
      deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + 30
      loop do
        result = backup.step(128)
        break if result == SQLite3::Constants::ErrorCode::DONE
        raise "SQLite backup failed" unless [SQLite3::Constants::ErrorCode::OK, SQLite3::Constants::ErrorCode::BUSY, SQLite3::Constants::ErrorCode::LOCKED].include?(result)
        raise "SQLite backup timed out" if Process.clock_gettime(Process::CLOCK_MONOTONIC) > deadline
        sleep 0.01 if result != SQLite3::Constants::ErrorCode::OK
      end
      backup.finish
      backup = nil
      raise "SQLite backup integrity check failed" unless destination.get_first_value("PRAGMA integrity_check") == "ok"
      # Make the completed backup independent of any WAL sidecar.
      destination.execute("PRAGMA journal_mode = DELETE")
      destination.close
      destination = nil
      File.chmod(0o600, temporary)
      File.rename(temporary, destination_path)
      destination_path
    ensure
      backup&.finish
      destination&.close
      source&.close
      FileUtils.rm_f(temporary) if temporary
    end
  end
end
