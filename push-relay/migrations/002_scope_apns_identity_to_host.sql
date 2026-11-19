DROP INDEX index_relay_registrations_on_apns_identity;
CREATE UNIQUE INDEX index_relay_registrations_on_host_apns_identity
  ON relay_registrations (host_origin, environment, apns_token_digest);
