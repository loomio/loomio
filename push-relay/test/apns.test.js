import assert from "node:assert/strict";
import crypto from "node:crypto";
import test from "node:test";
import { APNsClient, buildAPNsPayload, isPermanentAPNsFailure } from "../src/apns.js";

test("signs and caches APNs tokens with the correct environment key", () => {
  const production = crypto.generateKeyPairSync("ec", { namedCurve: "prime256v1" });
  const sandbox = crypto.generateKeyPairSync("ec", { namedCurve: "prime256v1" });
  const client = new APNsClient({
    teamId: "ABCDE12345",
    keyId: "PRODKEY123",
    privateKey: production.privateKey,
    sandbox: { keyId: "SANDKEY123", privateKey: sandbox.privateKey }
  });
  for (const [environment, pair, otherPair, keyId] of [
    ["production", production, sandbox, "PRODKEY123"],
    ["sandbox", sandbox, production, "SANDKEY123"]
  ]) {
    const token = client.providerToken(environment);
    const [header, claims, signature] = token.split(".");
    assert.equal(JSON.parse(Buffer.from(header, "base64url")).kid, keyId);
    assert.equal(JSON.parse(Buffer.from(claims, "base64url")).iss, "ABCDE12345");
    const data = Buffer.from(`${header}.${claims}`);
    const options = { key: pair.publicKey, dsaEncoding: "ieee-p1363" };
    assert.equal(crypto.verify("sha256", data, options, Buffer.from(signature, "base64url")), true);
    assert.equal(crypto.verify("sha256", data, { ...options, key: otherPair.publicKey }, Buffer.from(signature, "base64url")), false);
    assert.equal(client.providerToken(environment), token);
  }
});

test("supports existing APNs keys valid in both environments", () => {
  const pair = crypto.generateKeyPairSync("ec", { namedCurve: "prime256v1" });
  const client = new APNsClient({ teamId: "ABCDE12345", keyId: "LEGACY1234", privateKey: pair.privateKey });
  const token = client.providerToken("sandbox");
  const [header, claims, signature] = token.split(".");
  assert.equal(crypto.verify("sha256", Buffer.from(`${header}.${claims}`), {
    key: pair.publicKey, dsaEncoding: "ieee-p1363"
  }, Buffer.from(signature, "base64url")), true);
});

test("builds bounded generic payloads without host-controlled notification content", () => {
  const payload = JSON.parse(buildAPNsPayload({
    registrationId: "123e4567-e89b-42d3-a456-426614174000",
    eventId: "123e4567-e89b-42d3-a456-426614174001",
    kind: "notification",
    badge: 4
  }));

  assert.deepEqual(payload.aps.alert, {
    title: "New Loomio activity",
    body: "Open Loomio to view it."
  });
  assert.equal(payload.aps.badge, 4);
  assert.deepEqual(Object.keys(payload).sort(), ["aps", "event_id", "registration_id"]);
  assert.ok(Buffer.byteLength(JSON.stringify(payload)) < 4_096);
});

test("classifies only device-specific APNs failures as permanent", () => {
  assert.equal(isPermanentAPNsFailure(410, "Unregistered"), true);
  assert.equal(isPermanentAPNsFailure(400, "BadDeviceToken"), true);
  assert.equal(isPermanentAPNsFailure(400, "DeviceTokenNotForTopic"), true);
  assert.equal(isPermanentAPNsFailure(429, "TooManyRequests"), false);
  assert.equal(isPermanentAPNsFailure(500, "InternalServerError"), false);
});
