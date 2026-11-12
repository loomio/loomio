import assert from "node:assert/strict";
import test from "node:test";
import { createRateLimiter } from "../src/rate_limit.js";

function request(address = "192.0.2.1", forwarded) {
  return { socket: { remoteAddress: address }, headers: { "x-forwarded-for": forwarded } };
}

test("allows the existing bursts, refills at the configured rates, and separates route budgets", () => {
  let time = 0;
  const limit = createRateLimiter({ now: () => time });
  const client = request();
  for (let index = 0; index < 11; index++) assert.equal(limit(client, "registrations"), 0);
  assert.equal(limit(client, "registrations"), 2);
  for (let index = 0; index < 51; index++) assert.equal(limit(client, "deliveries"), 0);
  assert.equal(limit(client, "deliveries"), 1);

  time = 200;
  assert.equal(limit(client, "deliveries"), 0);
  assert.equal(limit(client, "registrations"), 2);
  time = 2_000;
  assert.equal(limit(client, "registrations"), 0);
  assert.equal(limit(client, "registrations"), 2);
  assert.equal(limit(request("192.0.2.2"), "registrations"), 0);
});

test("ignores forwarded addresses from an untrusted connection", () => {
  const limit = createRateLimiter({ trustedProxyCIDR: "172.18.0.0/16", now: () => 0 });
  for (let index = 0; index < 11; index++) {
    assert.equal(limit(request("192.0.2.1", `198.51.100.${index}`), "registrations"), 0);
  }
  assert.equal(limit(request("192.0.2.1", "198.51.100.99"), "registrations"), 2);
});

test("stops at the nearest untrusted forwarded hop and isolates actual proxy clients", () => {
  const limit = createRateLimiter({ trustedProxyCIDR: "172.18.0.0/16", now: () => 0 });
  for (let index = 0; index < 11; index++) {
    const forwarded = `198.51.100.${index}, 192.0.2.1, 172.18.0.3`;
    assert.equal(limit(request("::ffff:172.18.0.2", forwarded), "registrations"), 0);
  }
  assert.equal(limit(request("172.18.0.2", "198.51.100.99, 192.0.2.1"), "registrations"), 2);
  assert.equal(limit(request("172.18.0.2", "192.0.2.2"), "registrations"), 0);
});

test("malformed forwarding falls back to the proxy address instead of creating arbitrary keys", () => {
  const limit = createRateLimiter({ trustedProxyCIDR: "172.18.0.0/16", now: () => 0 });
  for (let index = 0; index < 11; index++) {
    assert.equal(limit(request("172.18.0.2", `invalid-${index}`), "registrations"), 0);
  }
  assert.equal(limit(request("172.18.0.2", ""), "registrations"), 2);
});

test("canonicalizes IPv6 and IPv4-mapped addresses so alternate spellings share a limit", () => {
  const limit = createRateLimiter({ trustedProxyCIDR: "fd00::/64", now: () => 0 });
  for (let index = 0; index < 11; index++) {
    assert.equal(limit(request("fd00::1", "2001:0db8:0000::1"), "registrations"), 0);
    assert.equal(limit(request("fd00::1", "::ffff:c000:201"), "registrations"), 0);
  }
  assert.equal(limit(request("fd00::1", "2001:db8::1"), "registrations"), 2);
  assert.equal(limit(request("fd00::1", "192.0.2.1"), "registrations"), 2);
  assert.equal(limit(request("::ffff:192.0.2.1"), "registrations"), 2);
});

test("bounds tracked clients without evicting active limits, then reclaims idle entries", () => {
  let time = 0;
  const limit = createRateLimiter({ now: () => time, entriesMax: 2 });
  for (let index = 0; index < 11; index++) assert.equal(limit(request(), "registrations"), 0);
  assert.equal(limit(request("192.0.2.2"), "registrations"), 0);
  for (let index = 3; index < 100; index++) {
    assert.equal(limit(request(`192.0.2.${index}`), "registrations"), 60);
  }
  assert.equal(limit(request(), "registrations"), 2);
  time = 59_000;
  assert.equal(limit(request(), "registrations"), 0);
  time = 60_000;
  assert.equal(limit(request("192.0.2.3"), "registrations"), 0);
  assert.equal(limit(request("192.0.2.4"), "registrations"), 60);
});

test("rejects invalid trusted proxy configuration before accepting requests", () => {
  for (const cidr of ["172.18.0.0", "172.18.0.0/33", "fd00::/129", "example.com/24", "172.18.0.0/-1", "172.18.0.0/16/8"]) {
    assert.throws(() => createRateLimiter({ trustedProxyCIDR: cidr }), /PROXY_TRUSTED_CIDR/);
  }
});
