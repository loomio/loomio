import http from "node:http";
import crypto from "node:crypto";
import { canonicalRequest, signRequest, validSignature } from "./crypto.js";
import { normalizedHTTPSOrigin } from "./security.js";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const APNS_TOKEN = /^[0-9a-f]{64,200}$/i;
const OPAQUE_TOKEN = /^lm_ra_[A-Za-z0-9_-]{43}$/;
const DELIVERY_KEY = /^[A-Za-z0-9_-]{43}$/;
const NONCE = /^[A-Za-z0-9_-]{22,86}$/;

function json(response, status, value) {
  const body = JSON.stringify(value);
  response.writeHead(status, {
    "content-type": "application/json",
    "cache-control": "no-store",
    "content-length": Buffer.byteLength(body)
  });
  response.end(body);
}

async function readBody(request) {
  const chunks = [];
  let size = 0;
  for await (const chunk of request) {
    size += chunk.length;
    if (size > 16_384) throw Object.assign(new Error("request too large"), { status: 413 });
    chunks.push(chunk);
  }
  const raw = Buffer.concat(chunks).toString("utf8");
  return { raw, value: raw ? JSON.parse(raw) : {} };
}

function exactKeys(value, keys) {
  return value && typeof value === "object" && !Array.isArray(value) &&
    Object.keys(value).sort().join("|") === [...keys].sort().join("|");
}

function registrationPath(pathname) {
  const match = pathname.match(/^\/v1\/registrations\/([0-9a-f-]+)(\/events)?$/i);
  return match && UUID.test(match[1]) ? { id: match[1], events: Boolean(match[2]) } : null;
}

function isJSONRequest(request) {
  return request.headers["content-type"]?.split(";", 1)[0].trim().toLowerCase() === "application/json";
}

async function authenticateHost({ request, path, rawBody, registration, repository, now }) {
  const timestamp = request.headers["x-loomio-timestamp"];
  const nonce = request.headers["x-loomio-nonce"];
  const signature = request.headers["x-loomio-signature"];
  if (!/^\d{10}$/.test(timestamp || "") || !NONCE.test(nonce || "")) return false;
  const seconds = Number(timestamp);
  if (Math.abs(Math.floor(now() / 1_000) - seconds) > 300) return false;
  const expected = signRequest({ method: request.method, path, timestamp, nonce, body: rawBody }, registration.deliveryKey);
  if (!validSignature(signature, expected)) return false;
  return await repository.claimNonce(registration.id, nonce, new Date((seconds + 600) * 1_000));
}

export function createServer({ repository, apns, verifyHostAuthorization, now = Date.now, logger = console }) {
  return http.createServer(async (request, response) => {
    const url = new URL(request.url, "http://relay.invalid");
    try {
      if (request.method === "GET" && url.pathname === "/health") {
        return json(response, 200, { status: "ok", protocol_version: 1 });
      }
      if (url.search) return json(response, 404, { error: "not_found" });
      if (!isJSONRequest(request)) return json(response, 415, { error: "unsupported_media_type" });

      const { raw, value } = await readBody(request);
      if (request.method === "POST" && url.pathname === "/v1/registrations") {
        if (!exactKeys(value, ["host_origin", "authorization", "apns_token", "environment"]) ||
            !OPAQUE_TOKEN.test(value.authorization) || !APNS_TOKEN.test(value.apns_token) ||
            !["sandbox", "production"].includes(value.environment)) {
          return json(response, 400, { error: "invalid_request" });
        }
        let hostOrigin;
        try { hostOrigin = normalizedHTTPSOrigin(value.host_origin); }
        catch { return json(response, 400, { error: "invalid_request" }); }
        const verified = await verifyHostAuthorization(hostOrigin, value.authorization);
        if (!exactKeys(verified, ["registration_id", "delivery_key"]) ||
            !UUID.test(verified.registration_id) || !DELIVERY_KEY.test(verified.delivery_key)) {
          throw new Error("invalid authorization verification response");
        }
        await repository.upsertRegistration({
          id: verified.registration_id,
          hostOrigin,
          apnsToken: value.apns_token.toLowerCase(),
          deliveryKey: verified.delivery_key,
          environment: value.environment
        });
        return json(response, 201, { registration_id: verified.registration_id });
      }

      const route = registrationPath(url.pathname);
      if (!route) return json(response, 404, { error: "not_found" });
      const registration = await repository.findRegistration(route.id);
      if (!registration) return json(response, 404, { error: "not_found" });
      if (!await authenticateHost({ request, path: url.pathname, rawBody: raw, registration, repository, now })) {
        return json(response, 401, { error: "invalid_signature" });
      }

      if (request.method === "DELETE" && !route.events && exactKeys(value, [])) {
        await repository.deleteRegistration(route.id);
        return json(response, 200, { deleted: true });
      }
      if (request.method === "POST" && route.events &&
          (exactKeys(value, ["event_id", "kind"]) || exactKeys(value, ["event_id", "kind", "badge"])) &&
          UUID.test(value.event_id) && ["notification", "test"].includes(value.kind) &&
          (value.badge === undefined || (Number.isInteger(value.badge) && value.badge >= 0 && value.badge <= 99_999))) {
        const claimed = await repository.claimEvent(route.id, value.event_id);
        if (!claimed) return json(response, 202, { accepted: true, duplicate: true });
        try {
          const result = await apns.send({
            token: registration.apnsToken,
            environment: registration.environment,
            registrationId: registration.id,
            eventId: value.event_id,
            kind: value.kind,
            badge: value.badge
          });
          if (result.permanent) {
            await repository.deleteRegistration(route.id);
            return json(response, 410, { error: "registration_gone" });
          }
          await repository.finishEvent(route.id, value.event_id, "delivered");
          return json(response, 202, { accepted: true });
        } catch (error) {
          await repository.finishEvent(route.id, value.event_id, "failed", error.reason || "apns_unavailable");
          response.setHeader("retry-after", "30");
          throw Object.assign(error, { status: 503, publicCode: "temporarily_unavailable" });
        }
      }
      return json(response, 405, { error: "method_not_allowed" });
    } catch (error) {
      const status = error.status || (error instanceof SyntaxError ? 400 : 502);
      const code = error.publicCode || (status === 400 ? "invalid_request" : "upstream_unavailable");
      logger.error?.("relay_request_failed", { method: request.method, path: url.pathname, status, code });
      return json(response, status, { error: code });
    }
  });
}
