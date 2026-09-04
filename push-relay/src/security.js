import dns from "node:dns/promises";
import net from "node:net";
import https from "node:https";

const blocked = new net.BlockList();
[
  ["0.0.0.0", 8], ["10.0.0.0", 8], ["100.64.0.0", 10],
  ["127.0.0.0", 8], ["169.254.0.0", 16], ["172.16.0.0", 12],
  ["192.0.0.0", 24], ["192.0.2.0", 24], ["192.88.99.0", 24],
  ["192.168.0.0", 16], ["198.18.0.0", 15], ["198.51.100.0", 24],
  ["203.0.113.0", 24],
  ["224.0.0.0", 4], ["240.0.0.0", 4]
].forEach(([network, prefix]) => blocked.addSubnet(network, prefix, "ipv4"));
[
  ["::", 128], ["::1", 128], ["100::", 64],
  ["fc00::", 7], ["fe80::", 10],
  ["ff00::", 8], ["64:ff9b::", 96], ["64:ff9b:1::", 48],
  ["2001::", 32], ["2001:db8::", 32], ["2002::", 16], ["3fff::", 20]
].forEach(([network, prefix]) => blocked.addSubnet(network, prefix, "ipv6"));

export function isPrivateAddress(address) {
  const family = net.isIP(address);
  if (family === 4) return blocked.check(address, "ipv4");
  if (family === 6) return blocked.check(address, "ipv6");
  return true;
}

export function normalizedHTTPSOrigin(input) {
  const url = new URL(input);
  if (url.protocol !== "https:" || url.username || url.password ||
      (url.pathname !== "/" && url.pathname !== "") || url.search || url.hash) {
    throw new Error("invalid host origin");
  }
  url.pathname = "";
  return url.origin;
}

export async function resolveHost(hostname, allowPrivateHosts = false) {
  const records = await dns.lookup(hostname, { all: true, verbatim: true });
  if (records.length === 0) throw new Error("host did not resolve");
  if (!allowPrivateHosts && records.some(({ address }) => isPrivateAddress(address))) {
    throw new Error("private host addresses are not allowed");
  }
  return records[0];
}

export async function postJSONPinned(url, payload, { allowPrivateHosts = false, timeoutMs = 8_000 } = {}) {
  const parsed = new URL(url);
  if (parsed.protocol !== "https:") throw new Error("HTTPS required");
  const resolved = await resolveHost(parsed.hostname, allowPrivateHosts);
  const body = Buffer.from(JSON.stringify(payload));

  return await new Promise((resolve, reject) => {
    const request = https.request({
      protocol: "https:",
      hostname: parsed.hostname,
      port: parsed.port || 443,
      path: `${parsed.pathname}${parsed.search}`,
      method: "POST",
      servername: parsed.hostname,
      headers: {
        accept: "application/json",
        "content-type": "application/json",
        "content-length": body.length
      },
      lookup: (_hostname, _options, callback) => callback(null, resolved.address, resolved.family),
      timeout: timeoutMs
    }, (response) => {
      const chunks = [];
      let size = 0;
      response.on("data", (chunk) => {
        size += chunk.length;
        if (size > 16_384) request.destroy(new Error("host response too large"));
        else chunks.push(chunk);
      });
      response.on("end", () => {
        if (response.statusCode !== 200) return reject(new Error("host rejected authorization"));
        if (response.headers.location) return reject(new Error("redirects are not allowed"));
        if (response.headers["content-type"]?.split(";", 1)[0].trim().toLowerCase() !== "application/json") {
          return reject(new Error("host response must be JSON"));
        }
        try { resolve(JSON.parse(Buffer.concat(chunks).toString("utf8"))); }
        catch { reject(new Error("invalid host response")); }
      });
    });
    request.on("timeout", () => request.destroy(new Error("host verification timed out")));
    request.on("error", reject);
    request.end(body);
  });
}
