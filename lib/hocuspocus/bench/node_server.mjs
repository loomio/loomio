// Baseline: the Node @hocuspocus/server with the settings Loomio used, and no
// auth callback. Install it outside the repo, e.g.
//   mkdir /tmp/hp && npm --prefix /tmp/hp install @hocuspocus/server@4.8.0
//   NODE_PATH=/tmp/hp/node_modules node lib/hocuspocus/bench/node_server.mjs 4600
import { createRequire } from 'node:module';
const require = createRequire(process.env.NODE_PATH.replace(/\/?$/, '/'));
const { Server } = require('@hocuspocus/server');
const server = new Server({ port: Number(process.argv[2] || 4600), timeout: 30000, quiet: true, flushDelay: process.env.FLUSH_DELAY === 'false' ? false : 0 });
await server.listen();
console.log(`node hocuspocus listening on ${server.configuration.port}`);
