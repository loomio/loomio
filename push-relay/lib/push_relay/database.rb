require "sqlite3"
require "fileutils"

module PushRelay
  module Database
    module_function

    def open(path)
      # Directory permissions also protect the WAL and shared-memory sidecars.
      unless path == ":memory:"
        FileUtils.mkdir_p(File.dirname(path), mode: 0o700)
        File.open(path, File::RDWR | File::CREAT, 0o600) {}
        File.chmod(0o600, path)
      end
      database = SQLite3::Database.new(path, results_as_hash: true)
      database.busy_timeout = 5_000
      database.execute_batch("PRAGMA foreign_keys = ON; PRAGMA journal_mode = WAL; PRAGMA synchronous = FULL;")
      database
    rescue Exception
      database&.close
      raise
    end

    def migrate(database, directory: File.expand_path("../../migrations", __dir__))
      database.execute("CREATE TABLE IF NOT EXISTS schema_migrations (filename TEXT PRIMARY KEY NOT NULL) STRICT")
      Dir.glob(File.join(directory, "*.sql")).sort.each do |path|
        filename = File.basename(path)
        database.transaction(:immediate) do
          next if database.get_first_value("SELECT 1 FROM schema_migrations WHERE filename = ?", [filename])
          database.execute_batch(File.read(path))
          database.execute("INSERT INTO schema_migrations (filename) VALUES (?)", [filename])
        end
      end
    end
  end
end
