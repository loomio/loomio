import assert from "node:assert/strict";
import crypto from "node:crypto";
import test from "node:test";
import { createServer } from "../src/app.js";
import { signRequest } from "../src/crypto.js";

const registrationId = "123e4567-e89b-42d3-a456-426614174000";
const eventId = "123e4567-e89b-42d3-a456-426614174001";
const deliveryKey = crypto.randomBytes(32).toString("base64url");

class MemoryRepository {
  constructor() {
    this.registrations = new Map();
    this.nonces = new Set();
    this.events = new Map();
  }

  async upsertRegistration(value) { this.registrations.set(value.id, { ...value }); }
  async findRegistration(id) { return this.registrations.get(id) || null; }
  async claimNonce(id, nonce) {
    const key = `${id}:${nonce}`;
    if (this.nonces.has(key)) return false;
    this.nonces.add(key);
    return true;
  }
  async claimEvent(id, event) {
    const key = `${id}:${event}`;
    if (this.events.has(key)) return false;
    this.events.set(key, "processing");
    return true;
  }
  async finishEvent(id, event, status) { this.events.set(`${id}:${event}`, status); }
  async deleteRegistration(id) { return this.registrations.delete(id); }
}

async function withServer(run) {
  const repository = new MemoryRepository();
  const sends = [];
  const apns = { send: async (value) => { sends.push(value); return { delivered: true }; } };
  const verifyHostAuthorization = async () => ({ registration_id: registrationId, delivery_key: deliveryKey });
  const now = () => 1_700_000_000_000;
  const logger = { error() {} };
  const server = createServer({ repository, apns, verifyHostAuthorization, now, logger });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  try {
    const { port } = server.address();
    await run({ base: `http://127.0.0.1:${port}`, repository, sends, now });
  } finally {
    await new Promise((resolve) => server.close(resolve));
  }
}

function signedHeaders(method, path, body, nonce = crypto.randomBytes(18).toString("base64url")) {
  const timestamp = "1700000000";
  return {
    "content-type": "application/json",
    "x-loomio-timestamp": timestamp,
    "x-loomio-nonce": nonce,
    "x-loomio-signature": signRequest({ method, path, timestamp, nonce, body }, deliveryKey)
  };
}

test("registers only after host authorization verification", async () => {
  await withServer(async ({ base, repository }) => {
    const response = await fetch(`${base}/v1/registrations`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        host_origin: "https://community.example",
        authorization: `lm_ra_${crypto.randomBytes(32).toString("base64url")}`,
        apns_token: "a".repeat(64),
        environment: "sandbox"
      })
    });

    assert.equal(response.status, 201);
    assert.equal(repository.registrations.get(registrationId).hostOrigin, "https://community.example");
  });
});

test("rejects non-JSON requests and unsigned query variations", async () => {
  await withServer(async ({ base, repository }) => {
    const registrationBody = JSON.stringify({
      host_origin: "https://community.example",
      authorization: `lm_ra_${crypto.randomBytes(32).toString("base64url")}`,
      apns_token: "a".repeat(64),
      environment: "sandbox"
    });
    const wrongMediaType = await fetch(`${base}/v1/registrations`, {
      method: "POST",
      headers: { "content-type": "text/plain" },
      body: registrationBody
    });
    assert.equal(wrongMediaType.status, 415);

    repository.registrations.set(registrationId, {
      id: registrationId, hostOrigin: "https://community.example", apnsToken: "a".repeat(64),
      deliveryKey, environment: "sandbox"
    });
    const path = `/v1/registrations/${registrationId}/events`;
    const body = JSON.stringify({ event_id: eventId, kind: "notification" });
    const query = await fetch(`${base}${path}?unexpected=true`, {
      method: "POST",
      headers: signedHeaders("POST", path, body),
      body
    });
    assert.equal(query.status, 404);
  });
});

test("authenticates, de-duplicates, and relays generic notification events", async () => {
  await withServer(async ({ base, repository, sends }) => {
    repository.registrations.set(registrationId, {
      id: registrationId, hostOrigin: "https://community.example", apnsToken: "a".repeat(64),
      deliveryKey, environment: "sandbox"
    });
    const path = `/v1/registrations/${registrationId}/events`;
    const body = JSON.stringify({ event_id: eventId, kind: "notification" });
    const nonce = crypto.randomBytes(18).toString("base64url");
    const first = await fetch(`${base}${path}`, { method: "POST", headers: signedHeaders("POST", path, body, nonce), body });
    const replay = await fetch(`${base}${path}`, { method: "POST", headers: signedHeaders("POST", path, body, nonce), body });
    const duplicate = await fetch(`${base}${path}`, { method: "POST", headers: signedHeaders("POST", path, body), body });

    assert.equal(first.status, 202);
    assert.equal(replay.status, 401);
    assert.equal(duplicate.status, 202);
    assert.equal((await duplicate.json()).duplicate, true);
    assert.equal(sends.length, 1);
    assert.deepEqual(Object.keys(sends[0]).sort(), ["badge", "environment", "eventId", "kind", "registrationId", "token"]);
  });
});
