import assert from "node:assert/strict";
import test from "node:test";
import { decrypt, encrypt, signRequest, validSignature } from "../src/crypto.js";

test("encrypted relay secrets round-trip without plaintext disclosure", () => {
  const key = Buffer.alloc(32, 7);
  const ciphertext = encrypt("device-secret", key);

  assert.equal(decrypt(ciphertext, key), "device-secret");
  assert.equal(ciphertext.includes("device-secret"), false);
});

test("request signatures bind method, path, time, nonce, and exact body", () => {
  const input = { method: "POST", path: "/v1/registrations/id/events", timestamp: "1700000000", nonce: "nonce", body: "{}" };
  const signature = signRequest(input, "delivery-key");

  assert.equal(validSignature(signature, signRequest(input, "delivery-key")), true);
  assert.equal(validSignature(signature, signRequest({ ...input, body: "{ }" }, "delivery-key")), false);
});
