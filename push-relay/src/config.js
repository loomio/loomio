import crypto from "node:crypto";

function required(name, env) {
  const value = env[name]?.trim();
  if (!value) throw new Error(`${name} is required`);
  return value;
}

export function loadConfig(env = process.env) {
  const encryptionKey = Buffer.from(required("RELAY_ENCRYPTION_KEY", env), "base64");
  if (encryptionKey.length !== 32) {
    throw new Error("RELAY_ENCRYPTION_KEY must be exactly 32 bytes encoded as base64");
  }

  const port = Number(env.PORT || "8080");
  if (!Number.isInteger(port) || port < 1 || port > 65_535) throw new Error("PORT must be an integer from 1 to 65535");

  const teamId = required("APNS_TEAM_ID", env);
  const keyId = required("APNS_KEY_ID", env);
  if (!/^[A-Z0-9]{10}$/.test(teamId)) throw new Error("APNS_TEAM_ID must be a 10-character Apple team ID");
  if (!/^[A-Z0-9]{10}$/.test(keyId)) throw new Error("APNS_KEY_ID must be a 10-character Apple key ID");

  const privateKey = required("APNS_PRIVATE_KEY", env).replaceAll("\\n", "\n");
  let parsedPrivateKey;
  try { parsedPrivateKey = crypto.createPrivateKey(privateKey); }
  catch { throw new Error("APNS_PRIVATE_KEY must be a valid private key"); }
  if (parsedPrivateKey.asymmetricKeyType !== "ec") throw new Error("APNS_PRIVATE_KEY must be an EC private key");

  return {
    port,
    databaseUrl: required("DATABASE_URL", env),
    encryptionKey,
    allowPrivateHosts: Object.hasOwn(env, "ALLOW_PRIVATE_HOSTS"),
    apns: {
      teamId,
      keyId,
      privateKey,
      topic: required("APNS_TOPIC", env)
    }
  };
}
