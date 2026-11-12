import assert from "node:assert/strict";
import crypto from "node:crypto";
import test from "node:test";
import { createServer } from "../src/app.js";
import { signRequest } from "../src/crypto.js";
import { createRateLimiter } from "../src/rate_limit.js";

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

async function withServer(run, options = {}) {
  const repository = new MemoryRepository();
  const sends = [];
  const verifications = [];
  const apns = { send: async (value) => { sends.push(value); return { delivered: true }; } };
  const verifyHostAuthorization = async (...args) => {
    verifications.push(args);
    return { registration_id: registrationId, delivery_key: deliveryKey };
  };
  const now = () => 1_700_000_000_000;
  const logger = { error() {} };
  const server = createServer({ repository, apns, verifyHostAuthorization, now, logger, ...options });
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  try {
    const { port } = server.address();
    await run({ base: `http://127.0.0.1:${port}`, repository, sends, verifications, now });
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

test("rejects oversized registration bodies before contacting a host", async () => {
  await withServer(async ({ base, verifications }) => {
    const response = await fetch(`${base}/v1/registrations`, {
      method: "POST", headers: { "content-type": "application/json" }, body: "x".repeat(16_385)
    });
    assert.equal(response.status, 413);
    assert.equal(verifications.length, 0);
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

test("limits registrations before parsing or calling the host, ignores spoofed headers, and leaves health checks available", async () => {
  let time = 0;
  await withServer(async ({ base, verifications }) => {
    const body = JSON.stringify({
      host_origin: "https://community.example",
      authorization: `lm_ra_${crypto.randomBytes(32).toString("base64url")}`,
      apns_token: "a".repeat(64),
      environment: "sandbox"
    });
    for (let index = 0; index < 11; index++) {
      const response = await fetch(`${base}/v1/registrations`, {
        method: "POST", headers: { "content-type": "application/json", "x-forwarded-for": `192.0.2.${index}` }, body
      });
      assert.equal(response.status, 201);
    }
    const blocked = await fetch(`${base}/v1/registrations`, {
      method: "POST", headers: { "content-type": "application/json" }, body: "invalid JSON"
    });
    assert.equal(blocked.status, 429);
    assert.equal(blocked.headers.get("retry-after"), "2");
    assert.equal(blocked.headers.get("cache-control"), "no-store");
    assert.deepEqual(await blocked.json(), { error: "rate_limited" });
    assert.equal(verifications.length, 11);
    assert.equal((await fetch(`${base}/health`)).status, 200);
    time = 2_000;
    const recovered = await fetch(`${base}/v1/registrations`, {
      method: "POST", headers: { "content-type": "application/json" }, body
    });
    assert.equal(recovered.status, 201);
    assert.equal(verifications.length, 12);
  }, { rateLimit: createRateLimiter({ now: () => time }) });
});

test("signed events and deletions share an IP limit before database and APNs work", async (t) => {
  let time = 0;
  await withServer(async ({ base, repository, sends }) => {
    repository.registrations.set(registrationId, {
      id: registrationId, hostOrigin: "https://community.example", apnsToken: "a".repeat(64),
      deliveryKey, environment: "sandbox"
    });
    const lookup = t.mock.method(repository, "findRegistration");
    const path = `/v1/registrations/${registrationId}/events`;
    const body = JSON.stringify({ event_id: eventId, kind: "notification" });
    for (let index = 0; index < 51; index++) {
      const response = await fetch(`${base}${path}`, { method: "POST", headers: signedHeaders("POST", path, body), body });
      assert.equal(response.status, 202);
    }
    const blocked = await fetch(`${base}/v1/registrations/${eventId}`, {
      method: "DELETE", headers: { "content-type": "application/json" }, body: "{}"
    });
    assert.equal(blocked.status, 429);
    assert.equal(blocked.headers.get("retry-after"), "1");
    assert.equal(lookup.mock.callCount(), 51);
    assert.equal(sends.length, 1);
    time = 200;
    const recovered = await fetch(`${base}${path}`, { method: "POST", headers: signedHeaders("POST", path, body), body });
    assert.equal(recovered.status, 202);
    assert.equal(lookup.mock.callCount(), 52);
  }, { rateLimit: createRateLimiter({ now: () => time }) });
});

test("unsigned attempts consume the delivery budget and unsupported routes never reach storage", async (t) => {
  await withServer(async ({ base, repository }) => {
    repository.registrations.set(registrationId, { id: registrationId, deliveryKey });
    const lookup = t.mock.method(repository, "findRegistration");
    const path = `/v1/registrations/${registrationId}/events`;
    for (let index = 0; index < 51; index++) {
      const response = await fetch(`${base}${path}`, {
        method: "POST", headers: { "content-type": "application/json" }, body: "{}"
      });
      assert.equal(response.status, 401);
    }
    const blocked = await fetch(`${base}${path}`, {
      method: "POST", headers: { "content-type": "application/json" }, body: "{}"
    });
    assert.equal(blocked.status, 429);
    assert.equal((await fetch(`${base}${path}`)).status, 405);
    assert.equal((await fetch(`${base}/unexpected`)).status, 404);
    assert.equal(lookup.mock.callCount(), 51);
  }, { rateLimit: createRateLimiter({ now: () => 0 }) });
});
