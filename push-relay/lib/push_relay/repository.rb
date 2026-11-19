require_relative "crypto"
require_relative "database"
require_relative "error"

module PushRelay
  class Repository
    def initialize(database, encryption_key, clock: -> { Time.now.to_f })
      @database, @encryption_key, @clock = database, encryption_key, clock
      @mutex = Mutex.new
      # Fail startup if the release migration was omitted.
      @database.execute("SELECT id FROM relay_registrations LIMIT 1")
    end

    def upsert_registration(id:, host_origin:, apns_token:, delivery_key:, environment:)
      id = id.downcase
      token_digest = Crypto.token_digest(apns_token, @encryption_key)
      values = [id, host_origin, Crypto.encrypt(apns_token, @encryption_key), token_digest,
        Crypto.encrypt(delivery_key, @encryption_key), environment, @clock.call, @clock.call]
      @mutex.synchronize do
        # A phone may register with several hosts. Replacement and insert stay atomic
        # within one host, and another host cannot take over a known registration UUID.
        @database.transaction(:immediate) do
          owner = @database.get_first_value("SELECT host_origin FROM relay_registrations WHERE id = ?", [id])
          raise Error.new(409, "registration_conflict") if owner && owner != host_origin
          @database.execute("DELETE FROM relay_registrations WHERE host_origin = ? AND environment = ? AND apns_token_digest = ? AND id <> ?", [host_origin, environment, token_digest, id])
          @database.execute(<<~SQL, values)
            INSERT INTO relay_registrations
              (id, host_origin, apns_token_ciphertext, apns_token_digest, delivery_key_ciphertext, environment, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ON CONFLICT (id) DO UPDATE SET
              host_origin = excluded.host_origin, apns_token_ciphertext = excluded.apns_token_ciphertext,
              apns_token_digest = excluded.apns_token_digest, delivery_key_ciphertext = excluded.delivery_key_ciphertext,
              environment = excluded.environment, updated_at = excluded.updated_at
          SQL
        end
      end
      { id: id }
    end

    def find_registration(id)
      row = @mutex.synchronize { @database.get_first_row("SELECT * FROM relay_registrations WHERE id = ?", [id.downcase]) }
      return unless row
      { id: row.fetch("id"), host_origin: row.fetch("host_origin"), environment: row.fetch("environment"),
        apns_token: Crypto.decrypt(row.fetch("apns_token_ciphertext"), @encryption_key),
        delivery_key: Crypto.decrypt(row.fetch("delivery_key_ciphertext"), @encryption_key) }
    end

    def claim_nonce(id, nonce, expires_at)
      @mutex.synchronize do
        @database.execute("INSERT INTO relay_nonces (registration_id, nonce, expires_at) VALUES (?, ?, ?) ON CONFLICT DO NOTHING", [id.downcase, nonce, expires_at.to_f])
        @database.changes == 1
      end
    end

    def claim_event(id, event_id)
      now = @clock.call
      @mutex.synchronize do
        @database.execute(<<~SQL, [id.downcase, event_id.downcase, now, now, now, now - 120])
          INSERT INTO relay_events (registration_id, event_id, started_at, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT (registration_id, event_id) DO UPDATE SET
            started_at = excluded.started_at, failed_at = NULL, last_error = NULL,
            attempts = relay_events.attempts + 1, updated_at = excluded.updated_at
          WHERE relay_events.delivered_at IS NULL
            AND (relay_events.failed_at IS NOT NULL OR relay_events.started_at < ?)
        SQL
        @database.changes == 1
      end
    end

    def finish_event(id, event_id, delivered:, error: nil)
      now = @clock.call
      @mutex.synchronize do
        @database.execute("UPDATE relay_events SET delivered_at = ?, failed_at = ?, last_error = ?, updated_at = ? WHERE registration_id = ? AND event_id = ?",
          [delivered ? now : nil, delivered ? nil : now, error, now, id.downcase, event_id.downcase])
      end
    end

    def delete_registration(id)
      @mutex.synchronize do
        @database.execute("DELETE FROM relay_registrations WHERE id = ?", [id.downcase])
        @database.changes == 1
      end
    end

    def cleanup
      now = @clock.call
      @mutex.synchronize do
        @database.execute("DELETE FROM relay_nonces WHERE expires_at < ?", [now])
        @database.execute("DELETE FROM relay_events WHERE updated_at < ?", [now - 30 * 86_400])
      end
    end

    def close
      @mutex.synchronize { @database.close }
    end
  end
end
