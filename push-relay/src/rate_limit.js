import net from "node:net";

const LIMITS = {
  registrations: { perMinute: 30, capacity: 11 },
  deliveries: { perMinute: 300, capacity: 51 }
};
const IDLE_MS = 60_000;

function normalizedAddress(address) {
  const version = net.isIP(address);
  if (!version) return null;
  return new net.SocketAddress({ address, family: version === 4 ? "ipv4" : "ipv6" })
    .address.replace(/^::ffff:/, "");
}

function proxyNetwork(cidr) {
  const trusted = new net.BlockList();
  if (!cidr) return trusted;
  const [address, prefix, extra] = cidr.split("/");
  const version = net.isIP(address);
  if (!version || extra !== undefined || !/^\d+$/.test(prefix || "") ||
      Number(prefix) > (version === 4 ? 32 : 128)) {
    throw new Error("PROXY_TRUSTED_CIDR must be an IPv4 or IPv6 CIDR");
  }
  trusted.addSubnet(address, Number(prefix), version === 4 ? "ipv4" : "ipv6");
  return trusted;
}

// Walk backwards through trusted proxies, stopping at the nearest untrusted hop.
// Client-supplied headers cannot replace the address appended by our TLS proxy.
function clientAddress(request, trusted) {
  const peer = normalizedAddress(request.socket.remoteAddress);
  let address = peer;
  const header = request.headers["x-forwarded-for"];
  const forwarded = typeof header === "string" ? header.split(",") : [];
  for (let index = forwarded.length - 1; index >= 0; index--) {
    if (!trusted.check(address, net.isIP(address) === 4 ? "ipv4" : "ipv6")) break;
    address = normalizedAddress(forwarded[index].trim());
    if (!address) return peer;
  }
  return address;
}

// Per-process token buckets match the previous Nginx rates and burst allowances.
// Expire idle clients and reject new keys at capacity rather than evicting active
// limits. A flood of new addresses must not grow memory or reset existing limits.
export function createRateLimiter({ trustedProxyCIDR, now = performance.now.bind(performance), entriesMax = 10_000 } = {}) {
  const trusted = proxyNetwork(trustedProxyCIDR);
  const entries = new Map();
  let cleanupAt = now() + IDLE_MS;

  return (request, group) => {
    const time = now();
    if (time >= cleanupAt) {
      for (const [key, entry] of entries) {
        if (time - entry.updatedAt >= IDLE_MS) entries.delete(key);
      }
      cleanupAt = time + IDLE_MS;
    }

    const key = `${group}:${clientAddress(request, trusted)}`;
    const { perMinute, capacity } = LIMITS[group];
    let entry = entries.get(key);
    if (!entry) {
      if (entries.size >= entriesMax) return Math.max(1, Math.ceil((cleanupAt - time) / 1_000));
      entry = { tokens: capacity, updatedAt: time };
      entries.set(key, entry);
    }
    entry.tokens = Math.min(capacity, entry.tokens + (time - entry.updatedAt) * perMinute / 60_000);
    entry.updatedAt = time;
    if (entry.tokens < 1) return Math.ceil((1 - entry.tokens) * 60 / perMinute);
    entry.tokens -= 1;
    return 0;
  };
}
