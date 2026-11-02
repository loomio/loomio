import { test, expect } from '../fixtures.mjs';

const DRAFT_TEXT  = 'hocuspocus draft persistence test'
const EDITOR      = '.comment-form .ProseMirror'
const SUBMIT_BTN  = '.comment-form__submit-button'

  // Confirms auth, WebSocket connection, and model-save all work end-to-end.
test('submits_content_via_collab_editor', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn(EDITOR, DRAFT_TEXT)
  await page.click(SUBMIT_BTN)
  await page.expectText('.new-comment', DRAFT_TEXT)
});

  // Types a draft, reloads (IndexedDB intact), and checks the draft survives.
  // Hocuspocus is a real-time relay; single-user draft persistence is IndexedDB.
test('restores_draft_after_reload', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn(EDITOR, DRAFT_TEXT)
  await page.refreshAndWait()
  await page.expectText(EDITOR, DRAFT_TEXT, 5000)
});
