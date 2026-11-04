import * as Y from 'yjs';
import { generateJSON, getSchema } from '@tiptap/core';
import { prosemirrorJSONToYXmlFragment } from '@tiptap/y-tiptap';

// Every client builds the initial Yjs state for a saved field itself, offline,
// and must produce byte-identical updates. The seed is written by client 0 at
// clock 0, so copies arriving from the server, IndexedDB or another tab are
// structs Yjs already has: they merge idempotently in any order, and deletions
// of seed text survive re-application.
//
// Two different seeds must never share client 0 and the same clocks in one
// document, or the document is corrupted. The seed hash therefore becomes part
// of the document name: different saved content (or a build whose schema
// encodes it differently) always gets a separate document. This also keeps
// stale drafts from attaching after someone saves new content.
export const SEED_CLIENT_ID = 0;

// The fragment name the Collaboration extension uses by default.
export const SEED_FIELD = 'default';

// 53-bit string hash (cyrb53). Synchronous, so the editor can start with the
// seed already applied. Collisions only matter between seeds of one field.
export function hashBytes(bytes, seed = 0) {
  let h1 = 0xdeadbeef ^ seed;
  let h2 = 0x41c6ce57 ^ seed;
  for (let i = 0; i < bytes.length; i++) {
    h1 = Math.imul(h1 ^ bytes[i], 2654435761);
    h2 = Math.imul(h2 ^ bytes[i], 1597334677);
  }
  h1 = Math.imul(h1 ^ (h1 >>> 16), 2246822507) ^ Math.imul(h2 ^ (h2 >>> 13), 3266489909);
  h2 = Math.imul(h2 ^ (h2 >>> 16), 2246822507) ^ Math.imul(h1 ^ (h1 >>> 13), 3266489909);
  return 4294967296 * (2097151 & h2) + (h1 >>> 0);
}

// Task items get a random uid when the HTML has none (legacy content). Assign
// one derived from the content and position instead, so every client parses
// the same document.
function fixTaskUids(html) {
  const template = document.createElement('template');
  template.innerHTML = html;
  const items = template.content.querySelectorAll('li[data-type="taskItem"], li[data-type="todo_item"]');
  const missing = Array.from(items).filter(item => !parseInt(item.getAttribute('data-uid')));
  if (missing.length === 0) return html;

  const htmlHash = hashBytes(new TextEncoder().encode(html));
  missing.forEach((item, index) => {
    item.setAttribute('data-uid', 1 + (hashBytes([index], htmlHash) % 89999999));
  });
  return template.innerHTML;
}

// Returns the seed update for `html` and a short hash to append to the
// document name. `extensions` must be the editor's content extensions: they
// define the schema the Collaboration extension writes with.
export function collabSeed(html, extensions) {
  const doc = new Y.Doc();
  doc.clientID = SEED_CLIENT_ID;
  const json = generateJSON(fixTaskUids(html || ''), extensions);
  prosemirrorJSONToYXmlFragment(getSchema(extensions), json, doc.getXmlFragment(SEED_FIELD));
  const update = Y.encodeStateAsUpdate(doc);
  doc.destroy();
  return { update, hash: hashBytes(update).toString(36) };
}
