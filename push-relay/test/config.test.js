import assert from "node:assert/strict";
import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import test from "node:test";
import { loadConfig } from "../src/config.js";

function validEnvironment() {
  const { privateKey } = crypto.generateKeyPairSync("ec", { namedCurve: "prime256v1" });
  return {
    PORT: "8080",
    DATABASE_URL: "postgres://relay@example.test/relay",
    RELAY_ENCRYPTION_KEY: crypto.randomBytes(32).toString("base64"),
    APNS_TEAM_ID: "ABCDE12345",
    APNS_KEY_ID: "FGHIJ67890",
    APNS_PRIVATE_KEY: privateKey.export({ type: "pkcs8", format: "pem" }),
    APNS_TOPIC: "org.loomio.mobile"
  };
}

test("validates startup secrets and treats boolean flags by presence", () => {
  const environment = validEnvironment();
  assert.equal(loadConfig(environment).allowPrivateHosts, false);

  environment.ALLOW_PRIVATE_HOSTS = "0";
  assert.equal(loadConfig(environment).allowPrivateHosts, true);

  environment.PORT = "not-a-port";
  assert.throws(() => loadConfig(environment), /PORT/);
});

test("rejects invalid encryption and APNs signing keys", () => {
  const environment = validEnvironment();
  environment.RELAY_ENCRYPTION_KEY = crypto.randomBytes(16).toString("base64");
  assert.throws(() => loadConfig(environment), /32 bytes/);

  Object.assign(environment, validEnvironment(), { APNS_PRIVATE_KEY: "not a key" });
  assert.throws(() => loadConfig(environment), /valid private key/);
});

test("loads separate sandbox credentials and rejects incomplete configuration", () => {
  const environment = validEnvironment();
  environment.APNS_SANDBOX_KEY_ID = "SANDBOX123";
  assert.throws(() => loadConfig(environment), /APNS_SANDBOX_PRIVATE_KEY/);

  environment.APNS_SANDBOX_PRIVATE_KEY = validEnvironment().APNS_PRIVATE_KEY;
  const config = loadConfig(environment);
  assert.equal(config.apns.sandbox.keyId, "SANDBOX123");
  assert.notEqual(config.apns.privateKey, config.apns.sandbox.privateKey);

  delete environment.APNS_SANDBOX_KEY_ID;
  assert.throws(() => loadConfig(environment), /APNS_SANDBOX_KEY_ID/);
});

test("reads mounted signing keys and rejects ambiguous key sources", () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), "relay-config-"));
  try {
    const environment = validEnvironment();
    const privateKey = environment.APNS_PRIVATE_KEY;
    environment.APNS_PRIVATE_KEY_FILE = path.join(directory, "apns.p8");
    fs.writeFileSync(environment.APNS_PRIVATE_KEY_FILE, privateKey, { mode: 0o600 });
    assert.throws(() => loadConfig(environment), /Set only one/);
    delete environment.APNS_PRIVATE_KEY;
    assert.equal(loadConfig(environment).apns.privateKey, privateKey.trim());
  } finally {
    fs.rmSync(directory, { recursive: true, force: true });
  }
});
