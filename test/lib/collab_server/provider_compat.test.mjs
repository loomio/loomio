// Compatibility of lib/collab_server with the real @hocuspocus/provider and yjs
// that the Vue client ships (from vue/node_modules), so a provider upgrade is
// tested against the Ruby server.
//
//   node --test test/lib/collab_server/provider_compat.test.mjs
//
// Starts compat_server.ru under Puma on a free port. To check that the
// tests describe Hocuspocus rather than this server, run them against the
// Node reference server instead; tests that need compat_server.ru's auth
// rules or controls are skipped:
//
//   COLLAB_SERVER_COMPAT_URL=ws://127.0.0.1:4600 node --test test/lib/collab_server/provider_compat.test.mjs
import assert from 'node:assert/strict';
import { spawn } from 'node:child_process';
import { once } from 'node:events';
import { createServer } from 'node:net';
import { after, before, test } from 'node:test';

const root = new URL('../../../', import.meta.url).pathname;
const Y = await import(root + 'vue/node_modules/yjs/dist/yjs.mjs');
const { HocuspocusProvider, HocuspocusProviderWebsocket } = await import(root + 'vue/node_modules/@hocuspocus/provider/dist/hocuspocus-provider.esm.js');

const externalUrl = process.env.COLLAB_SERVER_COMPAT_URL;
const needsCompatServer = { skip: externalUrl && 'needs compat_server.ru' };
let port;
let puma;
let url;
const providers = [];
let documentCount = 0;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

async function waitFor(condition, description, timeout = 10000) {
  const deadline = Date.now() + timeout;
  while (!condition()) {
    if (Date.now() > deadline) throw new Error(`timed out waiting for ${description}`);
    await sleep(20);
  }
}

const freePort = () => new Promise((resolve) => {
  const server = createServer().listen(0, '127.0.0.1', () => {
    const { port } = server.address();
    server.close(() => resolve(port));
  });
});

const control = (action) => fetch(`http://127.0.0.1:${port}/control/${action}`).then((response) => assert.equal(response.status, 200));

const uniqueName = (prefix = 'doc') => `${prefix}-${process.pid}-${++documentCount}`;

// A WebSocket that sends extra headers, as a browser sends cookies.
const webSocketWithHeaders = (headers) => class extends WebSocket {
  constructor(address, protocols) { super(address, { protocols, headers }); }
};

function client(name, options = {}) {
  const doc = new Y.Doc();
  const events = [];
  const provider = new HocuspocusProvider({
    url,
    name,
    document: doc,
    onAuthenticated: ({ scope }) => events.push(`authenticated:${scope}`),
    onAuthenticationFailed: ({ reason }) => events.push(`denied:${reason}`),
    onSynced: () => events.push('synced'),
    ...options,
  });
  providers.push(provider);
  return { doc, provider, events, text: doc.getText('text') };
}

before(async () => {
  if (externalUrl) {
    url = externalUrl;
    return;
  }
  port = await freePort();
  url = `ws://127.0.0.1:${port}`;
  puma = spawn('bundle', ['exec', 'puma', '-q', '-t', '2:2', '-b', `tcp://127.0.0.1:${port}`, 'test/lib/collab_server/compat_server.ru'], { cwd: root, stdio: 'inherit' });
  const deadline = Date.now() + 30000;
  for (;;) {
    try {
      if ((await fetch(`http://127.0.0.1:${port}/`)).status === 426) break;
    } catch (_) { /* not listening yet */ }
    if (Date.now() > deadline) throw new Error('compat server did not start');
    await sleep(200);
  }
});

after(async () => {
  providers.forEach((provider) => provider.destroy());
  if (!puma) return;
  puma.kill('SIGINT');
  await once(puma, 'exit');
});

test('authenticates read-write and syncs', async () => {
  const alice = client(uniqueName());
  await waitFor(() => alice.events.includes('synced'), 'sync');
  assert.deepEqual(alice.events, ['authenticated:read-write', 'synced']);
});

test('reports permission denied', needsCompatServer, async () => {
  const mallory = client(uniqueName('denied'));
  await waitFor(() => mallory.events.length > 0, 'an auth answer');
  assert.deepEqual(mallory.events, ['denied:permission-denied']);
});

test('identifies clients by the cookies of the WebSocket request', needsCompatServer, async () => {
  const name = uniqueName('private');
  const withCookie = client(name, { WebSocketPolyfill: webSocketWithHeaders({ Cookie: 'session=ok' }) });
  const withoutCookie = client(name);
  await waitFor(() => withCookie.events.includes('synced') && withoutCookie.events.length > 0, 'auth answers');
  assert.deepEqual(withoutCookie.events, ['denied:permission-denied']);
});

test('converges concurrent edits to text, XML, maps and arrays', async () => {
  const name = uniqueName();
  const alice = client(name);
  const bob = client(name);
  await waitFor(() => alice.provider.isSynced && bob.provider.isSynced, 'sync');

  for (let i = 0; i < 100; i++) {
    const editor = i % 2 ? alice : bob;
    editor.text.insert(Math.floor(Math.random() * (editor.text.length + 1)), i % 10 ? 'x' : 'naïve 😀 ', i % 3 ? undefined : { bold: true });
    if (i % 7 === 0 && editor.text.length > 3) editor.text.delete(1, 2);
    if (i % 5 === 0) editor.doc.getMap('map').set(`key${i % 3}`, { value: i, list: [i, 'two'] });
    if (i % 4 === 0) editor.doc.getArray('array').insert(0, [i]);
    if (i % 9 === 0) {
      const paragraph = new Y.XmlElement('paragraph');
      paragraph.insert(0, [new Y.XmlText(`paragraph ${i} 🎉`)]);
      editor.doc.getXmlFragment('prosemirror').insert(0, [paragraph]);
    }
  }

  await waitFor(() => Y.encodeStateVector(alice.doc).toString() === Y.encodeStateVector(bob.doc).toString(), 'convergence');
  assert.equal(alice.text.toString(), bob.text.toString());
  assert.deepEqual(alice.text.toDelta(), bob.text.toDelta());
  assert.deepEqual(alice.doc.getMap('map').toJSON(), bob.doc.getMap('map').toJSON());
  assert.deepEqual(alice.doc.getArray('array').toJSON(), bob.doc.getArray('array').toJSON());
  assert.equal(alice.doc.getXmlFragment('prosemirror').toString(), bob.doc.getXmlFragment('prosemirror').toString());
});

test('sends the whole document to a client that joins later', async () => {
  const name = uniqueName();
  const alice = client(name);
  await waitFor(() => alice.provider.isSynced, 'sync');
  alice.text.insert(0, 'written before anyone else arrived 😀');
  await waitFor(() => !alice.provider.hasUnsyncedChanges, 'the server to acknowledge');

  const carol = client(name);
  await waitFor(() => carol.text.toString() === alice.text.toString(), 'the late joiner to catch up');
});

test('acknowledges every change, so unsynced changes return to zero', async () => {
  const alice = client(uniqueName());
  await waitFor(() => alice.provider.isSynced, 'sync');
  for (let i = 0; i < 20; i++) alice.text.insert(0, 'x');
  assert.ok(alice.provider.hasUnsyncedChanges);
  await waitFor(() => !alice.provider.hasUnsyncedChanges, 'acknowledgements');
  assert.equal(alice.provider.unsyncedChanges, 0);
});

test('relays awareness and clears it when a client leaves', async () => {
  const name = uniqueName();
  const alice = client(name);
  const bob = client(name);
  await waitFor(() => alice.provider.isSynced && bob.provider.isSynced, 'sync');

  alice.provider.setAwarenessField('user', { name: 'Alice' });
  const aliceSeenByBob = () => [...bob.provider.awareness.getStates().values()].some((state) => state.user?.name === 'Alice');
  await waitFor(aliceSeenByBob, 'awareness to reach Bob');

  const carol = client(name);
  await waitFor(() => [...carol.provider.awareness.getStates().values()].some((state) => state.user?.name === 'Alice'), 'awareness to reach a late joiner');

  alice.provider.destroy();
  await waitFor(() => !aliceSeenByBob(), 'awareness to clear');
});

test('carries several documents over one WebSocket', async () => {
  const websocketProvider = new HocuspocusProviderWebsocket({ url });
  const first = client(uniqueName(), { websocketProvider });
  const second = client(uniqueName(), { websocketProvider });
  first.provider.attach();
  second.provider.attach();
  const observer = client(first.provider.configuration.name);
  await waitFor(() => first.provider.isSynced && second.provider.isSynced && observer.provider.isSynced, 'sync');

  first.text.insert(0, 'first');
  second.text.insert(0, 'second');
  await waitFor(() => observer.text.toString() === 'first', 'the first document');
  await sleep(200);
  assert.equal(observer.text.toString(), 'first');
  websocketProvider.destroy();
});

test('lets a document be closed and opened again on the same WebSocket', async () => {
  const name = uniqueName();
  const websocketProvider = new HocuspocusProviderWebsocket({ url });
  const first = client(name, { websocketProvider });
  first.provider.attach();
  await waitFor(() => first.provider.isSynced, 'sync');
  first.text.insert(0, 'kept');
  await waitFor(() => !first.provider.hasUnsyncedChanges, 'acknowledgement');
  const observer = client(name);
  await waitFor(() => observer.text.toString() === 'kept', 'the observer');

  first.provider.destroy();
  const again = client(name, { websocketProvider });
  again.provider.attach();
  await waitFor(() => again.text.toString() === 'kept', 'the reopened document');
  websocketProvider.destroy();
});

test('merges edits made while the server was away once it returns empty', needsCompatServer, async () => {
  const name = uniqueName();
  const alice = client(name);
  const bob = client(name);
  await waitFor(() => alice.provider.isSynced && bob.provider.isSynced, 'sync');
  alice.text.insert(0, 'shared ');
  await waitFor(() => bob.text.toString() === 'shared ', 'the first edit');

  await control('stop');
  alice.text.insert(alice.text.length, 'alice offline ');
  bob.text.insert(bob.text.length, 'bob offline ');
  await sleep(300);
  assert.ok(!alice.text.toString().includes('bob offline'));

  await control('start');
  await waitFor(() => alice.text.toString().includes('bob offline') && bob.text.toString().includes('alice offline'), 'reconnection', 30000);
  assert.equal(alice.text.toString(), bob.text.toString());
  assert.equal(alice.text.toString().split('shared').length - 1, 1);
});

test('syncs large documents', async () => {
  const name = uniqueName();
  const alice = client(name);
  await waitFor(() => alice.provider.isSynced, 'sync');
  alice.text.insert(0, 'lorem ipsum dolor sit amet, ünïcödé 😀 '.repeat(20000));
  const bob = client(name);
  await waitFor(() => bob.text.length === alice.text.length, 'the large document', 20000);
  assert.equal(bob.text.toString(), alice.text.toString());
});

test('ignores stateless messages without dropping the connection', async () => {
  const name = uniqueName();
  const alice = client(name);
  const bob = client(name);
  await waitFor(() => alice.provider.isSynced && bob.provider.isSynced, 'sync');
  alice.provider.sendStateless('hello');
  alice.text.insert(0, 'still connected');
  await waitFor(() => bob.text.toString() === 'still connected', 'the edit after a stateless message');
});
