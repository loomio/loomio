import * as Y from 'yjs';
import { Editor } from '@tiptap/core';
import Collaboration from '@tiptap/extension-collaboration';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { contentExtensions } from '@/components/lmo_textarea/content_extensions';
import { collabSeed, SEED_FIELD } from '@/components/lmo_textarea/collab_seed';

vi.mock('@/shared/services/session', () => ({ default: { user: () => ({ id: 42 }) } }));

// Opening a saved discussion description can find draft state in two places:
// the hocuspocus server's in-memory document and this browser's IndexedDB.
// Each may be absent or hold edits made on top of the saved content. Whatever
// combination arrives, in whatever order, the saved content must appear once
// and every edit must survive.
const saved = '<p>First</p><p>Second</p>';
const editors = [];
afterEach(() => editors.splice(0).forEach(editor => editor.destroy()));

// Mirrors collab_editor.vue: seed first, then the editor, then provider data.
const open = (html, ...updates) => {
  const doc = new Y.Doc();
  Y.applyUpdate(doc, collabSeed(html, contentExtensions()).update);
  const editor = new Editor({
    extensions: [...contentExtensions(), Collaboration.configure({ document: doc, field: SEED_FIELD })],
  });
  editors.push(editor);
  updates.forEach(update => Y.applyUpdate(doc, update));
  return { doc, editor };
};

// A draft made in another session: another user's edits held by the server,
// or this browser's edits held in IndexedDB.
const draft = (edit) => {
  const { doc, editor } = open(saved);
  edit(editor);
  return Y.encodeStateAsUpdate(doc);
};

const endOf = (editor, index) => {
  let pos = 0;
  for (let i = 0; i <= index; i++) pos += editor.state.doc.child(i).nodeSize;
  return pos - 1;
};
const appendTo = (index, text) => editor => editor.commands.insertContentAt(endOf(editor, index), text);
const deleteSecond = editor => editor.commands.deleteRange({ from: endOf(editor, 0) + 1, to: editor.state.doc.content.size });

const serverDraft = () => draft(appendTo(0, ' server'));
const localDraft = () => draft(editor => { deleteSecond(editor); appendTo(0, ' local')(editor); });

describe('opening a collaborative discussion description', () => {
  it('shows the saved content when neither server nor IndexedDB has a document', () => {
    expect(open(saved).editor.getHTML()).toBe('<p>First</p><p>Second</p>');
  });

  it('adds server edits once when IndexedDB has no document', () => {
    expect(open(saved, serverDraft()).editor.getHTML()).toBe('<p>First server</p><p>Second</p>');
  });

  it('restores an IndexedDB draft once when the server has no document', () => {
    expect(open(saved, localDraft()).editor.getHTML()).toBe('<p>First local</p>');
  });

  it.each([
    ['server first', () => [serverDraft(), localDraft()]],
    ['IndexedDB first', () => [localDraft(), serverDraft()]],
  ])('merges different server and IndexedDB edits, %s', (_order, updates) => {
    const html = open(saved, ...updates()).editor.getHTML();
    expect(html).toMatch(/^<p>First( server| local){2}<\/p>$/);
    expect(html.match(/First/g)).toHaveLength(1);
  });

  it('keeps text typed before the server and IndexedDB documents arrive', () => {
    const server = serverDraft();
    const local = localDraft();
    const { doc, editor } = open(saved);
    editor.commands.insertContentAt(1, 'Typed ');
    Y.applyUpdate(doc, local);
    Y.applyUpdate(doc, server);
    const html = editor.getHTML();
    expect(html).toMatch(/^<p>Typed First( server| local){2}<\/p>$/);
  });

  it('converges when two open editors exchange their documents', () => {
    const tabA = open(saved);
    const tabB = open(saved);
    appendTo(0, ' A')(tabA.editor);
    appendTo(1, ' B')(tabB.editor);
    Y.applyUpdate(tabA.doc, Y.encodeStateAsUpdate(tabB.doc));
    Y.applyUpdate(tabB.doc, Y.encodeStateAsUpdate(tabA.doc));
    expect(tabA.editor.getHTML()).toBe('<p>First A</p><p>Second B</p>');
    expect(tabB.editor.getHTML()).toBe(tabA.editor.getHTML());
  });

  // The hocuspocus sync protocol: each side sends what the other lacks.
  const connect = (client, server) => {
    Y.applyUpdate(server, Y.encodeStateAsUpdate(client.doc, Y.encodeStateVector(server)));
    Y.applyUpdate(client.doc, Y.encodeStateAsUpdate(server, Y.encodeStateVector(client.doc)));
  };

  it('pushes offline edits to a server that comes back with no document', () => {
    const client = open(saved);
    appendTo(0, ' offline')(client.editor);
    const server = new Y.Doc();
    connect(client, server);
    expect(client.editor.getHTML()).toBe('<p>First offline</p><p>Second</p>');
    expect(open(saved, Y.encodeStateAsUpdate(server)).editor.getHTML()).toBe(client.editor.getHTML());
  });

  it('merges offline edits with edits the server gained meanwhile', () => {
    const client = open(saved);
    deleteSecond(client.editor);
    appendTo(0, ' offline')(client.editor);
    const server = new Y.Doc();
    Y.applyUpdate(server, serverDraft());
    connect(client, server);
    const html = client.editor.getHTML();
    expect(html).toMatch(/^<p>First( server| offline){2}<\/p>$/);
    expect(open(saved, Y.encodeStateAsUpdate(server)).editor.getHTML()).toBe(html);
  });

  // After someone saves new content, drafts of the old content live under a
  // different document name and are never delivered to the new editor.
  it('names a separate document once the record is saved with new content', () => {
    const before = collabSeed(saved, contentExtensions()).hash;
    expect(collabSeed('<p>First server</p><p>Second</p>', contentExtensions()).hash).not.toBe(before);
    expect(collabSeed(saved, contentExtensions()).hash).toBe(before);
  });
});
