CREATE TABLE relay_registrations (
  id TEXT PRIMARY KEY NOT NULL,
  host_origin TEXT NOT NULL,
  apns_token_ciphertext TEXT NOT NULL,
  apns_token_digest TEXT NOT NULL,
  delivery_key_ciphertext TEXT NOT NULL,
  environment TEXT NOT NULL CHECK (environment IN ('sandbox', 'production')),
  created_at REAL NOT NULL,
  updated_at REAL NOT NULL
) STRICT;
CREATE UNIQUE INDEX index_relay_registrations_on_apns_identity
  ON relay_registrations (environment, apns_token_digest);
CREATE INDEX index_relay_registrations_on_host_origin ON relay_registrations (host_origin);
CREATE TABLE relay_nonces (
  registration_id TEXT NOT NULL REFERENCES relay_registrations(id) ON DELETE CASCADE,
  nonce TEXT NOT NULL,
  expires_at REAL NOT NULL,
  PRIMARY KEY (registration_id, nonce)
) STRICT;
CREATE INDEX index_relay_nonces_on_expires_at ON relay_nonces (expires_at);
CREATE TABLE relay_events (
  registration_id TEXT NOT NULL REFERENCES relay_registrations(id) ON DELETE CASCADE,
  event_id TEXT NOT NULL,
  started_at REAL NOT NULL,
  delivered_at REAL,
  failed_at REAL,
  attempts INTEGER NOT NULL DEFAULT 1 CHECK (attempts > 0),
  last_error TEXT,
  created_at REAL NOT NULL,
  updated_at REAL NOT NULL,
  CHECK (delivered_at IS NULL OR failed_at IS NULL),
  PRIMARY KEY (registration_id, event_id)
) STRICT;
CREATE INDEX index_relay_events_on_updated_at ON relay_events (updated_at);
