import crypto from "node:crypto";
import http2 from "node:http2";
import { base64urlJSON } from "./crypto.js";

const PERMANENT_REASONS = new Set(["BadDeviceToken", "DeviceTokenNotForTopic", "Unregistered"]);

export function buildAPNsPayload({ registrationId, eventId, kind, badge }) {
  const alert = kind === "test"
    ? { title: "Loomio notifications are working", body: "This device is ready for Loomio updates." }
    : { title: "New Loomio activity", body: "Open Loomio to view it." };
  const aps = { alert, sound: "default" };
  if (Number.isInteger(badge) && badge >= 0) aps.badge = badge;
  return JSON.stringify({ aps, registration_id: registrationId, event_id: eventId });
}

export function isPermanentAPNsFailure(status, reason) {
  return status === 410 || PERMANENT_REASONS.has(reason);
}

export class APNsClient {
  constructor(config) {
    this.config = config;
    this.cachedToken = null;
    this.cachedAt = 0;
  }

  providerToken() {
    const now = Math.floor(Date.now() / 1_000);
    if (this.cachedToken && now - this.cachedAt < 3_000) return this.cachedToken;
    const header = base64urlJSON({ alg: "ES256", kid: this.config.keyId });
    const claims = base64urlJSON({ iss: this.config.teamId, iat: now });
    const signingInput = `${header}.${claims}`;
    const signature = crypto.sign("sha256", Buffer.from(signingInput), {
      key: this.config.privateKey,
      dsaEncoding: "ieee-p1363"
    }).toString("base64url");
    this.cachedAt = now;
    this.cachedToken = `${signingInput}.${signature}`;
    return this.cachedToken;
  }

  async send({ token, environment, registrationId, eventId, kind, badge }) {
    const authority = environment === "production"
      ? "https://api.push.apple.com"
      : "https://api.sandbox.push.apple.com";
    const payload = buildAPNsPayload({ registrationId, eventId, kind, badge });

    return await new Promise((resolve, reject) => {
      const client = http2.connect(authority);
      client.setTimeout(10_000, () => client.destroy(new Error("APNs timeout")));
      client.on("error", reject);
      const request = client.request({
        ":method": "POST",
        ":path": `/3/device/${token}`,
        authorization: `bearer ${this.providerToken()}`,
        "apns-topic": this.config.topic,
        "apns-push-type": "alert",
        "apns-priority": "10",
        "apns-id": eventId,
        "content-type": "application/json"
      });
      const chunks = [];
      let status = 0;
      request.setEncoding("utf8");
      request.on("response", (headers) => { status = Number(headers[":status"]); });
      request.on("data", (chunk) => chunks.push(chunk));
      request.on("end", () => {
        client.close();
        let reason = "";
        try { reason = JSON.parse(chunks.join(""))?.reason || ""; } catch {}
        if (status === 200) resolve({ delivered: true });
        else if (isPermanentAPNsFailure(status, reason)) resolve({ permanent: true, reason });
        else reject(Object.assign(new Error("APNs delivery failed"), { status, reason }));
      });
      request.on("error", (error) => { client.destroy(); reject(error); });
      request.end(payload);
    });
  }
}
