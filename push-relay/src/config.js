import crypto from "node:crypto";
import fs from "node:fs";

function required(name, env) {
  const value = env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

function signingKey(env, keyIdName, privateKeyName) {
  const keyId = required(keyIdName, env);
  if (!/^[A-Z0-9]{10}$/.test(keyId)) throw new Error(`${keyIdName} must be a 10-character Apple key ID`);

  const keyFileName = `${privateKeyName}_FILE`;
  if (env[privateKeyName]?.trim() && env[keyFileName]?.trim()) {
    throw new Error(`Set only one of ${privateKeyName} or ${keyFileName}`);
  }
  const privateKey = env[keyFileName]?.trim()
    ? fs.readFileSync(env[keyFileName].trim(), "utf8").trim()
    : required(privateKeyName, env).replaceAll("\\n", "\n");
  let parsedPrivateKey;
  try { parsedPrivateKey = crypto.createPrivateKey(privateKey); }
  catch { throw new Error(`${privateKeyName} must be a valid private key`); }
  if (parsedPrivateKey.asymmetricKeyType !== "ec") throw new Error(`${privateKeyName} must be an EC private key`);
  return { keyId, privateKey };
}

export function loadConfig(env = process.env) {
  const encryptionKey = Buffer.from(required("RELAY_ENCRYPTION_KEY", env), "base64");
  if (encryptionKey.length !== 32) {
    throw new Error("RELAY_ENCRYPTION_KEY must be exactly 32 bytes encoded as base64");
  }

  const port = Number(env.PORT || "8080");
  if (!Number.isInteger(port) || port < 1 || port > 65_535) throw new Error("PORT must be an integer from 1 to 65535");

  const teamId = required("APNS_TEAM_ID", env);
  if (!/^[A-Z0-9]{10}$/.test(teamId)) throw new Error("APNS_TEAM_ID must be a 10-character Apple team ID");
  const production = signingKey(env, "APNS_KEY_ID", "APNS_PRIVATE_KEY");
  const sandboxConfigured = ["APNS_SANDBOX_KEY_ID", "APNS_SANDBOX_PRIVATE_KEY", "APNS_SANDBOX_PRIVATE_KEY_FILE"]
    .some(name => env[name]?.trim());
  const sandbox = sandboxConfigured ? signingKey(env, "APNS_SANDBOX_KEY_ID", "APNS_SANDBOX_PRIVATE_KEY") : null;

  return {
    port,
    databaseUrl: required("DATABASE_URL", env),
    encryptionKey,
    allowPrivateHosts: Object.hasOwn(env, "ALLOW_PRIVATE_HOSTS"),
    apns: {
      teamId,
      ...production,
      sandbox,
      topic: required("APNS_TOPIC", env)
    }
  };
}
