import assert from "node:assert/strict";
import test from "node:test";
import { isPrivateAddress, normalizedHTTPSOrigin } from "../src/security.js";

test("normalizes HTTPS origins and rejects URLs with authority or path data", () => {
  assert.equal(normalizedHTTPSOrigin("https://Community.Example:8443/"), "https://community.example:8443");
  assert.throws(() => normalizedHTTPSOrigin("http://community.example"));
  assert.throws(() => normalizedHTTPSOrigin("https://user@community.example"));
  assert.throws(() => normalizedHTTPSOrigin("https://community.example/mobile"));
});

test("blocks private, reserved, mapped, and documentation addresses", () => {
  ["127.0.0.1", "10.1.2.3", "100.64.0.1", "169.254.169.254", "192.0.2.1", "198.18.0.1", "198.51.100.1", "203.0.113.1", "::1", "fd00::1", "::ffff:127.0.0.1", "2001:db8::1", "3fff::1"].forEach((address) => {
    assert.equal(isPrivateAddress(address), true, address);
  });
  assert.equal(isPrivateAddress("8.8.8.8"), false);
  assert.equal(isPrivateAddress("2606:4700:4700::1111"), false);
});
