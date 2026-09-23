import crypto from "node:crypto";

export function sha256(value) {
  return crypto.createHash("sha256").update(value).digest("hex");
}

export function tokenDigest(value, key) {
  return crypto.createHmac("sha256", key).update(value).digest("hex");
}

export function encrypt(value, key) {
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv("aes-256-gcm", key, iv);
  const ciphertext = Buffer.concat([cipher.update(value, "utf8"), cipher.final()]);
  return [iv, cipher.getAuthTag(), ciphertext].map((part) => part.toString("base64url")).join(".");
}

export function decrypt(value, key) {
  const [iv, tag, ciphertext] = value.split(".").map((part) => Buffer.from(part, "base64url"));
  if (!iv || !tag || !ciphertext) throw new Error("invalid encrypted value");
  const decipher = crypto.createDecipheriv("aes-256-gcm", key, iv);
  decipher.setAuthTag(tag);
  return Buffer.concat([decipher.update(ciphertext), decipher.final()]).toString("utf8");
}

export function canonicalRequest({ method, path, timestamp, nonce, body }) {
  return [method.toUpperCase(), path, timestamp, nonce, sha256(body)].join("\n");
}

export function signRequest(input, key) {
  return crypto.createHmac("sha256", key).update(canonicalRequest(input)).digest("base64url");
}

export function validSignature(candidate, expected) {
  const left = Buffer.from(candidate || "", "utf8");
  const right = Buffer.from(expected, "utf8");
  return left.length === right.length && crypto.timingSafeEqual(left, right);
}

export function base64urlJSON(value) {
  return Buffer.from(JSON.stringify(value)).toString("base64url");
}
