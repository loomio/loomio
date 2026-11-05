// Load generator for comparing collaboration servers. Runs real
// @hocuspocus/provider clients (from vue/node_modules) and samples the server
// process's CPU time and resident memory with ps.
//
//   node lib/collab_server/bench/bench.mjs <ws url> <server pid> <scenario>
//
// Scenarios:
//   typing   50 documents × 4 editors, each typing 10 characters a second for
//            30 seconds; reports how long an edit takes to reach the others.
//   storm    300 clients join one document holding 40 KB of text at once;
//            reports time until every client is synced.
//   memory   500 documents of about 10 KB, each with 2 clients connected.
import { execSync } from 'node:child_process';

const vue = new URL('../../../vue/node_modules/', import.meta.url).pathname;
const Y = await import(vue + 'yjs/dist/yjs.mjs');
const { HocuspocusProvider, HocuspocusProviderWebsocket } = await import(vue + '@hocuspocus/provider/dist/hocuspocus-provider.esm.js');

const [url, pid, scenario] = process.argv.slice(2);
const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

function sample() {
  const [cpu, rss] = execSync(`ps -o time=,rss= -p ${pid}`).toString().trim().split(/\s+/);
  const parts = cpu.split(':').map(Number);
  const seconds = parts.reduce((total, part) => total * 60 + part, 0);
  return { cpu: seconds, rss: Number(rss) * 1024 };
}

function client(name, onUpdate) {
  const doc = new Y.Doc();
  const websocketProvider = new HocuspocusProviderWebsocket({ url, autoConnect: true });
  const provider = new HocuspocusProvider({ websocketProvider, name, document: doc });
  provider.attach();
  const synced = new Promise(resolve => provider.on('synced', resolve));
  if (onUpdate) doc.getMap('stamps').observe((event) => { if (event.transaction.origin === provider) onUpdate(event); });
  return { doc, provider, synced, text: doc.getText('t') };
}

const percentile = (values, p) => {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.min(sorted.length - 1, Math.floor(sorted.length * p))];
};
const mb = (bytes) => (bytes / 1024 / 1024).toFixed(1) + ' MB';

const results = { scenario, before: sample() };
let peakRss = results.before.rss;
const sampler = setInterval(() => { peakRss = Math.max(peakRss, sample().rss); }, 250);
const started = performance.now();

if (scenario === 'typing') {
  const latencies = [];
  const timeline = [];
  const documents = 50, editors = 4, seconds = 30, rate = 10;
  const groups = [];
  for (let d = 0; d < documents; d++) {
    const clients = [];
    for (let e = 0; e < editors; e++) {
      clients.push(client(`typing-${d}`, (event) => {
        const now = performance.now();
        event.keysChanged.forEach(key => { const sent = event.target.get(key); latencies.push(now - sent); timeline.push([sent, now - sent]); });
      }));
    }
    groups.push(clients);
  }
  await Promise.all(groups.flat().map(c => c.synced));
  results.connectMs = Math.round(performance.now() - started);
  const typingStarted = performance.now();
  let edits = 0;
  while (performance.now() - typingStarted < seconds * 1000) {
    for (const clients of groups) {
      for (const [index, c] of clients.entries()) {
        c.doc.transact(() => {
          c.text.insert(Math.floor(Math.random() * (c.text.length + 1)), 'x');
          c.doc.getMap('stamps').set(`${index}-${edits}`, performance.now());
        });
        edits++;
      }
    }
    await sleep(1000 / rate);
  }
  await sleep(2000);
  results.edits = edits;
  results.editsPerSecond = Math.round(edits / seconds);
  results.latencyMs = { p50: percentile(latencies, 0.5).toFixed(1), p95: percentile(latencies, 0.95).toFixed(1), p99: percentile(latencies, 0.99).toFixed(1), samples: latencies.length };
  if (process.env.TIMELINE) {
    const windows = {};
    for (const [sent, latency] of timeline) (windows[Math.floor((sent - typingStarted) / 2000)] ||= []).push(latency);
    results.timeline = Object.fromEntries(Object.entries(windows).map(([w, l]) => [w * 2 + 's', percentile(l, 0.95).toFixed(0)]));
  }
  const converged = groups.every(clients => clients.every(c => c.text.toString() === clients[0].text.toString()));
  results.converged = converged;
} else if (scenario === 'storm') {
  const seed = client('storm');
  await seed.synced;
  seed.text.insert(0, 'lorem ipsum dolor sit amet '.repeat(1500));
  await sleep(1000);
  const joinStarted = performance.now();
  const clients = Array.from({ length: 300 }, () => client('storm'));
  await Promise.all(clients.map(c => c.synced));
  results.allSyncedMs = Math.round(performance.now() - joinStarted);
  results.converged = clients.every(c => c.text.length === seed.text.length);
} else if (scenario === 'memory') {
  const clients = [];
  for (let d = 0; d < 500; d++) {
    const writer = client(`memory-${d}`);
    clients.push(writer, client(`memory-${d}`));
  }
  await Promise.all(clients.map(c => c.synced));
  for (let i = 0; i < clients.length; i += 2) {
    for (let n = 0; n < 40; n++) clients[i].text.insert(clients[i].text.length, 'lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. '.slice(0, 250));
  }
  await sleep(5000);
  results.converged = clients.every((c, i) => c.text.length === clients[i - (i % 2)].text.length);
}

clearInterval(sampler);
const after = sample();
results.serverCpuSeconds = +(after.cpu - results.before.cpu).toFixed(2);
results.wallSeconds = +((performance.now() - started) / 1000).toFixed(1);
results.serverCpuPercent = Math.round(100 * results.serverCpuSeconds / results.wallSeconds);
results.rssBefore = mb(results.before.rss);
results.rssPeak = mb(peakRss);
results.rssAfter = mb(after.rss);
delete results.before;
console.log(JSON.stringify(results));
process.exit(0);
