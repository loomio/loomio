import { test, expect } from '../fixtures.mjs';

const DRAFT_TEXT  = 'hocuspocus draft persistence test'
const EDITOR      = '.comment-form .ProseMirror'
const SUBMIT_BTN  = '.comment-form__submit-button'

  // Confirms auth, WebSocket connection, and model-save all work end-to-end.
test('submits_content_via_collab_editor', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator(EDITOR).fill(DRAFT_TEXT)
  await page.locator(SUBMIT_BTN).click()
  await expect(page.locator('.new-comment')).toContainText(DRAFT_TEXT)
});

  // Types a draft, reloads (IndexedDB intact), and checks the draft survives.
  // Hocuspocus is a real-time relay; single-user draft persistence is IndexedDB.
test('restores_draft_after_reload', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator(EDITOR).fill(DRAFT_TEXT)
  await page.reload()
  await expect(page.locator(EDITOR)).toContainText(DRAFT_TEXT)
});
