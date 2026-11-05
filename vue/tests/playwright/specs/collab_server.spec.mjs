import { randomUUID } from 'node:crypto';
import { test, expect } from '../fixtures.mjs';
import { comment, commentForm, postComment } from '../helpers/threads.mjs';
import { editor } from '../helpers/editor.mjs';
import { startCollabServer, stopCollabServer } from '../helpers/collabServer.mjs';

const draft = 'collaborative draft persistence test';
const saved = 'Saved description';

const description = page => editor(page.locator('.discussion-form'));
// The description editor once the collaboration server holds its document.
const serverSynced = page => page.locator('.discussion-form .collab-editor--server-synced');

// Counts occurrences in the editor, so doubled seed content fails loudly.
async function expectOccurrences(page, text, count) {
  await expect.poll(async () => (await description(page).innerText()).split(text).length - 1, {
    message: `"${text}" appears ${count} time(s)`
  }).toBe(count);
}

// Each test saves distinct content. Database IDs are reused after a reset; the
// content hash keeps drafts from earlier tests and retries from attaching.
async function openDescriptionEditor(page) {
  const text = `${saved} ${randomUUID()}`;
  await page.goto(`/dev/setup_discussion_html_description_edit?text=${encodeURIComponent(text)}`);
  await expect(description(page)).toContainText(saved);
}

// Types at the end of the editor in one input, leaving existing content in place.
async function typeAtEnd(page, text) {
  const field = description(page);
  await field.click();
  await field.press('ControlOrMeta+End');
  await page.keyboard.insertText(text);
}

// Waits until IndexedDB holds the draft, so a reload can restore it.
async function expectDraftStored(page, text) {
  await expect.poll(() => page.evaluate(async text => {
    const request = store => new Promise(resolve => { store.onsuccess = () => resolve(store.result); });
    for (const { name } of await indexedDB.databases()) {
      const db = await request(indexedDB.open(name));
      if (db.objectStoreNames.contains('updates')) {
        const updates = await request(db.transaction('updates').objectStore('updates').getAll());
        if (updates.some(update => new TextDecoder().decode(update).includes(text))) {
          db.close();
          return true;
        }
      }
      db.close();
    }
    return false;
  }, text), { message: `IndexedDB holds "${text}"` }).toBe(true);
}

// A second tab on the same description, sharing the first tab's storage.
async function openSecondTab(page) {
  const other = await page.context().newPage();
  await other.goto(page.url());
  await expect(description(other)).toContainText(saved);
  return other;
}

test.afterEach(async () => {
  await startCollabServer();
});

test.describe('comments', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/dev/setup_discussion');
  });

  // Covers authentication, the WebSocket connection and saving the model.
  test('posts a comment written in the collaborative editor', async ({ page }) => {
    await postComment(page, draft);
    await expect(comment(page, draft)).toBeVisible();
  });

  // The collaboration server relays live edits; a single person's draft persists in IndexedDB.
  test('keeps a draft after reloading', async ({ page }) => {
    await editor(commentForm(page)).fill(draft);
    await page.reload();
    await expect(editor(commentForm(page))).toContainText(draft);
  });
});

test.describe('saved descriptions', () => {
  // Nothing on the server or in IndexedDB: the saved content shows once, and
  // still once after the server sync.
  test('opens the saved description once', async ({ page }) => {
    await openDescriptionEditor(page);
    await expect(serverSynced(page)).toBeAttached();
    await expectOccurrences(page, saved, 1);
  });

  // Text typed before any sync arrives is kept.
  test('keeps text typed immediately', async ({ page }) => {
    await openDescriptionEditor(page);
    await typeAtEnd(page, ' typed early');
    await expect(serverSynced(page)).toBeAttached();
    await expect(description(page)).toContainText('typed early');
    await expectOccurrences(page, saved, 1);
  });

  // With the server down there is no sync to wait for; text typed straight
  // away must survive, then reach the server when it returns.
  test('keeps text typed while the server is down', async ({ page }) => {
    await stopCollabServer();
    await openDescriptionEditor(page);
    await typeAtEnd(page, ' typed offline');
    await expect(description(page)).toContainText('typed offline');
    await expectOccurrences(page, saved, 1);

    await startCollabServer();
    await expect(serverSynced(page)).toBeAttached({ timeout: 30_000 });
    await expect(description(page)).toContainText('typed offline');
    await expectOccurrences(page, saved, 1);
  });

  // Two tabs on one description: no doubled content, edits travel both ways.
  test('syncs two tabs without doubling', async ({ page }) => {
    await openDescriptionEditor(page);
    const other = await openSecondTab(page);
    await typeAtEnd(other, ' from B');
    await expect(description(page)).toContainText('from B', { timeout: 10_000 });

    await typeAtEnd(page, ' from A');
    await expect(description(other)).toContainText('from A', { timeout: 10_000 });
    await expectOccurrences(other, saved, 1);
    await expectOccurrences(other, 'from B', 1);
  });

  // The server has no persistence, so a restart loses its documents. The
  // draft returns from IndexedDB and must not merge with a second copy of the
  // saved content.
  test('restores a draft after the server restarts', async ({ page }) => {
    await openDescriptionEditor(page);
    await typeAtEnd(page, ' kept draft');
    await expectDraftStored(page, ' kept draft');
    const editUrl = page.url();

    await page.goto('/dashboard');
    await stopCollabServer();
    await startCollabServer();
    await page.goto(editUrl);
    await expect(description(page)).toContainText('kept draft');
    await expect(serverSynced(page)).toBeAttached({ timeout: 30_000 });
    await expectOccurrences(page, saved, 1);
    await expectOccurrences(page, 'kept draft', 1);
  });

  // Both tabs edit while the server is down. When it returns, empty, each
  // tab's edits reach the other and the saved content is not doubled.
  test('syncs edits made while the server was down', async ({ page }) => {
    await openDescriptionEditor(page);
    const other = await openSecondTab(page);
    await stopCollabServer();

    await typeAtEnd(other, ' B offline');
    await typeAtEnd(page, ' A offline');
    await expect(description(page)).not.toContainText('B offline');

    await startCollabServer();
    await expect(description(page)).toContainText('B offline', { timeout: 30_000 });
    await expectOccurrences(page, saved, 1);
    await expect(description(other)).toContainText('A offline', { timeout: 30_000 });
    await expectOccurrences(other, saved, 1);
  });

  // A draft of old content must not attach after someone saves new content.
  test('shows newly saved content instead of a stale draft', async ({ page }) => {
    await openDescriptionEditor(page);
    await typeAtEnd(page, ' stale draft');
    await expectDraftStored(page, ' stale draft');

    await page.goto('/dev/update_html_description_elsewhere');
    await expect(description(page)).toContainText('Saved elsewhere');
    await expect(serverSynced(page)).toBeAttached();
    await expect(description(page)).not.toContainText('stale draft');
    await expect(description(page)).not.toContainText(saved);
    await expectOccurrences(page, 'Saved elsewhere', 1);
  });
});
