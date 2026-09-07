import { decrypt, encrypt, tokenDigest } from "./crypto.js";

export class PostgresRepository {
  constructor(pool, encryptionKey) {
    this.pool = pool;
    this.encryptionKey = encryptionKey;
  }

  async upsertRegistration({ id, hostOrigin, apnsToken, deliveryKey, environment }) {
    const values = [
      id,
      hostOrigin,
      encrypt(apnsToken, this.encryptionKey),
      tokenDigest(apnsToken, this.encryptionKey),
      encrypt(deliveryKey, this.encryptionKey),
      environment
    ];
    const client = await this.pool.connect();
    try {
      await client.query("BEGIN");
      await client.query(
        `DELETE FROM relay_registrations
         WHERE environment = $6 AND apns_token_digest = $4 AND id <> $1`, values
      );
      await client.query(
        `INSERT INTO relay_registrations
          (id, host_origin, apns_token_ciphertext, apns_token_digest, delivery_key_ciphertext, environment)
         VALUES ($1, $2, $3, $4, $5, $6)
         ON CONFLICT (id) DO UPDATE SET
          host_origin = EXCLUDED.host_origin,
          apns_token_ciphertext = EXCLUDED.apns_token_ciphertext,
          apns_token_digest = EXCLUDED.apns_token_digest,
          delivery_key_ciphertext = EXCLUDED.delivery_key_ciphertext,
          environment = EXCLUDED.environment,
          updated_at = now()`, values
      );
      await client.query("COMMIT");
    } catch (error) {
      await client.query("ROLLBACK");
      throw error;
    } finally {
      client.release();
    }
    return { id };
  }

  async findRegistration(id) {
    const { rows } = await this.pool.query("SELECT * FROM relay_registrations WHERE id = $1", [id]);
    const row = rows[0];
    if (!row) return null;
    return {
      id: row.id,
      hostOrigin: row.host_origin,
      apnsToken: decrypt(row.apns_token_ciphertext, this.encryptionKey),
      deliveryKey: decrypt(row.delivery_key_ciphertext, this.encryptionKey),
      environment: row.environment
    };
  }

  async claimNonce(id, nonce, expiresAt) {
    const result = await this.pool.query(
      `INSERT INTO relay_nonces (registration_id, nonce, expires_at)
       VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`, [id, nonce, expiresAt]
    );
    return result.rowCount === 1;
  }

  async claimEvent(id, eventId) {
    const { rows } = await this.pool.query(
      `INSERT INTO relay_events (registration_id, event_id, status)
       VALUES ($1, $2, 'processing')
       ON CONFLICT (registration_id, event_id) DO UPDATE SET
         status = 'processing', attempts = relay_events.attempts + 1, updated_at = now()
       WHERE relay_events.status = 'failed'
          OR (relay_events.status = 'processing' AND relay_events.updated_at < now() - interval '2 minutes')
       RETURNING status`, [id, eventId]
    );
    return rows.length === 1;
  }

  async finishEvent(id, eventId, status, lastError = null) {
    await this.pool.query(
      `UPDATE relay_events SET status = $3, last_error = $4, updated_at = now()
       WHERE registration_id = $1 AND event_id = $2`, [id, eventId, status, lastError]
    );
  }

  async deleteRegistration(id) {
    const result = await this.pool.query("DELETE FROM relay_registrations WHERE id = $1", [id]);
    return result.rowCount === 1;
  }

  async cleanup() {
    await this.pool.query("DELETE FROM relay_nonces WHERE expires_at < now()");
    await this.pool.query("DELETE FROM relay_events WHERE updated_at < now() - interval '30 days'");
  }
}
