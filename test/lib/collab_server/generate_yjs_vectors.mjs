// Generates Yjs test vectors: random Yjs edits plus the results
// of Yjs's own update operations, which the Ruby port must reproduce exactly.
//
//   node test/lib/collab_server/generate_yjs_vectors.mjs [output path]
//
// The Ruby tests run this when the vectors are missing or out of date
// (support.rb); the output goes to tmp/collab_server/yjs_vectors.json.
//
// Uses the yjs package installed for the Vue client.
import { createRequire } from 'node:module';
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(new URL('../../../vue/package.json', import.meta.url));
const Y = require('yjs');

let seed = 42;
const random = () => { seed = (seed * 1103515245 + 12345) % 2147483648; return seed / 2147483648; };
const pick = (list) => list[Math.floor(random() * list.length)];
const words = ['hello', 'world', 'kia ora', 'naïve', 'emoji 😀', '🎉🎉', 'a', '', 'Ω≈ç√', 'line\nbreak'];
const b64 = (bytes) => Buffer.from(bytes).toString('base64');

function edit(doc) {
  const text = doc.getText('text');
  const map = doc.getMap('map');
  const array = doc.getArray('array');
  const xml = doc.getXmlFragment('prosemirror');
  switch (Math.floor(random() * 9)) {
    case 0: case 1: {
      const word = pick(words);
      if (word) text.insert(Math.floor(random() * (text.length + 1)), word, random() < 0.3 ? { bold: true } : undefined);
      break;
    }
    case 2: if (text.length > 0) {
      const index = Math.floor(random() * text.length);
      text.delete(index, Math.min(text.length - index, 1 + Math.floor(random() * 5)));
    } break;
    case 3: map.set(pick(['a', 'b', 'c']), pick([1, 2.5, 'x', null, true, { nested: [1, 'two'] }, new Uint8Array([1, 2, 3]), 2 ** 40])); break;
    case 4: array.insert(Math.floor(random() * (array.length + 1)), [pick([1, 'two', { three: 3 }]), pick([false, -7, 1e-3])]); break;
    case 5: if (array.length > 0) array.delete(Math.floor(random() * array.length), 1); break;
    case 6: {
      const paragraph = new Y.XmlElement('paragraph');
      paragraph.setAttribute('align', pick(['left', 'center']));
      paragraph.insert(0, [new Y.XmlText(pick(words) || 'x')]);
      xml.insert(Math.floor(random() * (xml.length + 1)), [paragraph]);
      break;
    }
    case 7: if (text.length > 1) text.format(0, Math.floor(random() * text.length), { italic: random() < 0.5 ? true : null }); break;
    case 8: if (xml.length > 0) xml.delete(Math.floor(random() * xml.length), 1); break;
  }
}

function scenario(name, clientCount, steps, gc) {
  const docs = Array.from({ length: clientCount }, (_, i) => {
    const doc = new Y.Doc({ gc });
    doc.clientID = 1000 + i * 7919;
    return doc;
  });
  const updates = [];
  docs.forEach((doc) => doc.on('update', (update) => updates.push(update)));
  for (let step = 0; step < steps; step++) {
    const doc = pick(docs);
    doc.transact(() => { for (let i = 0; i < 1 + Math.floor(random() * 3); i++) edit(doc); });
    if (random() < 0.3) {
      const [a, b] = [pick(docs), pick(docs)];
      Y.applyUpdate(b, Y.encodeStateAsUpdate(a, Y.encodeStateVector(b)));
    }
  }
  const shuffled = [...updates].sort(() => random() - 0.5);
  const partial = updates.filter(() => random() < 0.6);
  const merged = Y.mergeUpdates(updates);
  const peer = docs[0];
  const peerVector = Y.encodeStateVector(peer);
  return {
    name,
    updates: updates.map(b64),
    shuffled: shuffled.map(b64),
    partial: partial.map(b64),
    merged: b64(merged),
    merged_shuffled: b64(Y.mergeUpdates(shuffled)),
    merged_partial: b64(Y.mergeUpdates(partial)),
    state_vector: b64(Y.encodeStateVectorFromUpdate(merged)),
    state_vector_partial: b64(Y.encodeStateVectorFromUpdate(Y.mergeUpdates(partial))),
    peer_state_vector: b64(peerVector),
    diff: b64(Y.diffUpdate(merged, peerVector)),
    diff_partial: b64(Y.diffUpdate(Y.mergeUpdates(partial), peerVector)),
  };
}

const scenarios = [
  scenario('one client', 1, 40, true),
  scenario('two clients', 2, 80, true),
  scenario('five clients without gc', 5, 150, false),
  scenario('five clients with gc', 5, 150, true),
];
const output = process.argv[2] || fileURLToPath(new URL('../../../tmp/collab_server/yjs_vectors.json', import.meta.url));
mkdirSync(dirname(output), { recursive: true });
const generator = readFileSync(fileURLToPath(import.meta.url), 'utf8');
writeFileSync(output, JSON.stringify({ yjs: require('yjs/package.json').version, generator, scenarios }) + '\n');
console.log(`wrote ${output}`);
