import * as Y from 'yjs';
import { describe, expect, it, vi } from 'vitest';
import { yXmlFragmentToProsemirrorJSON } from '@tiptap/y-tiptap';
import { contentExtensions } from '@/components/lmo_textarea/content_extensions';
import { collabSeed, SEED_FIELD } from '@/components/lmo_textarea/collab_seed';

vi.mock('@/shared/services/session', () => ({ default: { user: () => ({ id: 42 }) } }));

const html = '<p>Hello <strong>world</strong></p><ul><li><p>one</p></li></ul>';
const seeded = (content = html) => {
  const doc = new Y.Doc();
  Y.applyUpdate(doc, collabSeed(content, contentExtensions()).update);
  return doc;
};
const text = doc => doc.getXmlFragment(SEED_FIELD).toString();
const sync = (a, b) => {
  Y.applyUpdate(a, Y.encodeStateAsUpdate(b, Y.encodeStateVector(a)));
  Y.applyUpdate(b, Y.encodeStateAsUpdate(a, Y.encodeStateVector(b)));
};

describe('collaborative editor seed', () => {
  it('is byte-identical across clients and changes with the content', () => {
    const a = collabSeed(html, contentExtensions());
    const b = collabSeed(html, contentExtensions());
    expect(b.update).toEqual(a.update);
    expect(b.hash).toBe(a.hash);
    expect(collabSeed('<p>Hello</p>', contentExtensions()).hash).not.toBe(a.hash);
  });

  it('merges seeds from several clients without doubling content', () => {
    const tabA = seeded();
    const tabB = seeded();
    const server = seeded();
    sync(tabA, server);
    sync(tabB, server);
    sync(tabA, tabB);
    expect(text(tabA)).toBe(text(seeded()));
    expect(text(tabB)).toBe(text(tabA));
  });

  it('keeps edits made by each client before they sync', () => {
    const tabA = seeded();
    const tabB = seeded();
    tabA.getXmlFragment(SEED_FIELD).insert(0, [new Y.XmlElement('paragraph')]);
    tabB.getXmlFragment(SEED_FIELD).delete(1, 1);
    sync(tabA, tabB);
    expect(text(tabA)).toBe(text(tabB));
    expect(tabA.getXmlFragment(SEED_FIELD).length).toBe(2);
  });

  it('keeps deletions of seed content when the seed is applied again', () => {
    const draft = seeded();
    draft.getXmlFragment(SEED_FIELD).delete(0, 2);
    const stored = Y.encodeStateAsUpdate(draft);

    // A later visit seeds again, then IndexedDB delivers the stored draft.
    const reload = seeded();
    Y.applyUpdate(reload, stored);
    Y.applyUpdate(reload, collabSeed(html, contentExtensions()).update);
    expect(reload.getXmlFragment(SEED_FIELD).length).toBe(0);
  });

  it('seeds an empty record with a paragraph so first edits do not race to create one', () => {
    const json = yXmlFragmentToProsemirrorJSON(seeded('').getXmlFragment(SEED_FIELD));
    expect(json.content.map(node => node.type)).toEqual(['paragraph']);
  });

  it('gives task items without a uid the same uid on every client', () => {
    const legacy = '<ul data-type="taskList"><li data-type="taskItem"><p>a</p></li><li data-type="taskItem"><p>b</p></li></ul>';
    const a = collabSeed(legacy, contentExtensions());
    expect(collabSeed(legacy, contentExtensions()).update).toEqual(a.update);
    const uids = text(seeded(legacy)).match(/uid="(\d+)"/g);
    expect(uids).toHaveLength(2);
    expect(uids[0]).not.toBe(uids[1]);
  });
});
