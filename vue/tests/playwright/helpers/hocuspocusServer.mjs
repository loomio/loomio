// Stops and restarts the hocuspocus server that bin/e2e started, to test
// clients while it is unavailable and after it returns with no documents.
// bin/e2e kills whatever listens on the port when the run ends.
import { execSync, spawn } from 'node:child_process';
import net from 'node:net';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { expect } from '@playwright/test';
import { port as appPort } from './server.mjs';

const port = Number(process.env.HOCUSPOCUS_PORT || 4445);
const serverPath = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../../../../hocuspocus/server.mjs');

function listening() {
  return new Promise(resolve => {
    const socket = net.connect(port, 'localhost');
    socket.once('connect', () => { socket.destroy(); resolve(true); });
    socket.once('error', () => resolve(false));
  });
}

export async function stopHocuspocus() {
  const pids = execSync(`lsof -ti tcp:${port} -sTCP:LISTEN || true`).toString().trim().split('\n').filter(Boolean);
  pids.forEach(pid => process.kill(Number(pid)));
  await expect.poll(listening, { message: 'hocuspocus stops', timeout: 10_000 }).toBe(false);
}

export async function startHocuspocus() {
  if (await listening()) return;
  spawn('node', [serverPath], {
    env: { ...process.env, APP_URL: `http://localhost:${appPort}`, HOCUSPOCUS_PORT: String(port) },
    detached: true,
    stdio: 'ignore',
  }).unref();
  await expect.poll(listening, { message: 'hocuspocus starts', timeout: 10_000 }).toBe(true);
}
