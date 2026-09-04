import assert from "node:assert/strict";
import crypto from "node:crypto";
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
