import { test, expect } from '../fixtures.mjs';
import { comment, commentForm, postComment } from '../helpers/threads.mjs';
import { editor } from '../helpers/editor.mjs';

const draft = 'hocuspocus draft persistence test';

test.beforeEach(async ({ page }) => {
  await page.goto('/dev/setup_discussion');
});

// Covers authentication, the WebSocket connection and saving the model.
test('posts a comment written in the collaborative editor', async ({ page }) => {
  await postComment(page, draft);
  await expect(comment(page, draft)).toBeVisible();
});

// Hocuspocus relays live edits; a single person's draft persists in IndexedDB.
test('keeps a draft after reloading', async ({ page }) => {
  await editor(commentForm(page)).fill(draft);
  await page.reload();
  await expect(editor(commentForm(page))).toContainText(draft);
});
