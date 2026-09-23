import pg from "pg";
import { loadConfig } from "./config.js";
import { APNsClient } from "./apns.js";
import { createServer } from "./app.js";
import { PostgresRepository } from "./repository.js";
import { postJSONPinned } from "./security.js";

const config = loadConfig();
const pool = new pg.Pool({ connectionString: config.databaseUrl, max: 10 });
pool.on("error", () => console.error(JSON.stringify({ event: "relay_database_pool_error" })));
const repository = new PostgresRepository(pool, config.encryptionKey);
const apns = new APNsClient(config.apns);
const verifyHostAuthorization = (origin, authorization) => postJSONPinned(
  `${origin}/api/v1/mobile/relay-authorizations/verify`,
  { authorization },
  { allowPrivateHosts: config.allowPrivateHosts }
);

const server = createServer({ repository, apns, verifyHostAuthorization });
server.requestTimeout = 15_000;
server.headersTimeout = 10_000;
server.keepAliveTimeout = 5_000;
server.maxHeadersCount = 32;
server.maxRequestsPerSocket = 100;

const cleanup = setInterval(() => repository.cleanup().catch(() => {
  console.error(JSON.stringify({ event: "relay_cleanup_failed" }));
}), 60 * 60 * 1_000);
cleanup.unref();

server.listen(config.port, "0.0.0.0", () => {
  console.log(JSON.stringify({ event: "relay_started", port: config.port }));
});

let isShuttingDown = false;
async function shutdown() {
  if (isShuttingDown) return;
  isShuttingDown = true;
  server.close();
  await pool.end();
  process.exit(0);
}
process.on("SIGTERM", shutdown);
process.on("SIGINT", shutdown);
