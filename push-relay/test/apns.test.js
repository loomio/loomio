import assert from "node:assert/strict";
import test from "node:test";
import { buildAPNsPayload, isPermanentAPNsFailure } from "../src/apns.js";

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
