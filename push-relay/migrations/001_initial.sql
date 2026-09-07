CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS relay_registrations (
  id uuid PRIMARY KEY,
  host_origin text NOT NULL,
  apns_token_ciphertext text NOT NULL,
  apns_token_digest text NOT NULL,
  delivery_key_ciphertext text NOT NULL,
  environment text NOT NULL CHECK (environment IN ('sandbox', 'production')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS index_relay_registrations_on_apns_identity
  ON relay_registrations (environment, apns_token_digest);
CREATE INDEX IF NOT EXISTS index_relay_registrations_on_host_origin
  ON relay_registrations (host_origin);

CREATE TABLE IF NOT EXISTS relay_nonces (
  registration_id uuid NOT NULL REFERENCES relay_registrations(id) ON DELETE CASCADE,
  nonce text NOT NULL,
  expires_at timestamptz NOT NULL,
  PRIMARY KEY (registration_id, nonce)
);
CREATE INDEX IF NOT EXISTS index_relay_nonces_on_expires_at ON relay_nonces (expires_at);

CREATE TABLE IF NOT EXISTS relay_events (
  registration_id uuid NOT NULL REFERENCES relay_registrations(id) ON DELETE CASCADE,
  event_id uuid NOT NULL,
  status text NOT NULL CHECK (status IN ('processing', 'delivered', 'failed')),
  attempts integer NOT NULL DEFAULT 1 CHECK (attempts > 0),
  last_error text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (registration_id, event_id)
);
CREATE INDEX IF NOT EXISTS index_relay_events_on_updated_at ON relay_events (updated_at);
