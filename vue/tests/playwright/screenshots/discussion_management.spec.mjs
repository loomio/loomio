import { test, expect, expectLabel } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await expect(page.locator('.group-page').first()).toBeVisible()
  await expect(page.locator('.topic-preview').first()).toBeVisible()
  await page.evaluate("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')")
  await expect(page.locator('.manual-topic').first()).toBeVisible()
}

async function openThreadMenu(page) {
  await page.setViewportSize({ width: 1200, height: 1200 })
  await openGroup(page);
  await page.locator('.manual-topic .action-menu').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
}

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator('.new-comment').first()).toBeVisible()
}

async function openCopyMarkdownDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_copy_markdown')
  await expect(page.locator('.topic-page').first()).toBeVisible()
  await expect(page.locator('.new-comment').first()).toBeVisible()
  await expectLabel(page.locator('.topic-page'), 'Run the six-week bottle trial with three cafes')
}

async function selectCommentForMove(page) {
  await openDiscussion(page);
  await page.locator('.new-comment .action-menu').click()
  await page.locator('.v-overlay--active .action-dock__button--move_event').click()
  await expect(page.locator('.discussion-fork-actions').first()).toBeVisible()
  await expect(page.locator('.topic-item__is-forking').first()).toBeVisible()
  await page.locator('.context-panel__heading').click()
}

async function openMoveItemsModal(page) {
  await selectCommentForMove(page);
  await page.locator('.discussion-fork-actions__move').click()
  await expect(page.locator('.modal-launcher .v-card').first()).toBeVisible()
  await expectLabel(page.locator('.modal-launcher .v-card'), 'Move items')
}

test('thread_management', async ({ page, manual: screenshot }) => {
  await openThreadMenu(page);
  await screenshot.captureRegion('discussions/discussion_management/thread_management', [
    '.manual-topic',
    '.v-overlay--active .v-list'
  ], {padding: 16, width: 1200, height: 1200});
});

test('permissions_manage_threads', async ({ page, manual: screenshot }) => {
  await openGroup(page);
  await page.locator('.group-page .action-menu--btn').click()
  await page.locator('.v-overlay .action-dock__button--edit_group').click()
  await expect(page.locator('.group-form').first()).toBeVisible()
  await page.locator('.group-form__permissions-tab').click()
  await expect(page.locator('.group-form__members-can-edit-discussions').first()).toBeVisible()
  await page.evaluate("const input = document.querySelector('.group-form__members-can-edit-discussions input'); if (!input.checked) input.click()")
  await screenshot.captureElement('discussions/discussion_management/permissions_manage_threads', '.group-form__members-can-edit-discussions', {
    width: 1100,
    height: 1000
  });
});

test('pin_thread', async ({ page, manual: screenshot }) => {
  await openThreadMenu(page);
  await screenshot.captureRegion('discussions/discussion_management/pin_thread', [
    '.group-page .v-tabs',
    '.discussions-panel > .d-flex',
    '.manual-topic',
    '.v-overlay--active .v-list'
  ], {
    spotlight: {selector: '.v-overlay--active .action-dock__button--pin_thread', padding: 8, radius: 12},
    padding: 16,
    width: 1200,
    height: 1200
  });
});

test('thread_edit', async ({ page, manual: screenshot }) => {
  await openThreadMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--edit_discussion').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await screenshot.captureElement('discussions/discussion_management/thread_edit', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('thread_move_group', async ({ page, manual: screenshot }) => {
  await openThreadMenu(page);
  await screenshot.captureRegion('discussions/discussion_management/thread_move_group', [
    '.manual-topic',
    '.v-overlay--active .v-list'
  ], {
    spotlight: {selector: '.v-overlay--active .action-dock__button--move_thread', padding: 8, radius: 12},
    padding: 16,
    width: 1200,
    height: 1200
  });
});

test('move_thread_select', async ({ page, manual: screenshot }) => {
  await openThreadMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--move_thread').click()
  await expect(page.locator('.move-topic-form').first()).toBeVisible()
  await page.locator('.move-topic-form__group-dropdown .v-field').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await screenshot.captureRegion('discussions/discussion_management/move_thread_select', [
    '.move-topic-form',
    '.v-overlay--active .v-list'
  ], {padding: 12, width: 1100, height: 1200});
});

test('comment_move', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.new-comment .action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--move_event').first()).toBeVisible()
  await screenshot.captureRegion('discussions/using_discussions/comment_move', [
    '.new-comment',
    '.v-overlay--active .v-list'
  ], {
    spotlight: {selector: '.v-overlay--active .action-dock__button--move_event', padding: 8, radius: 12},
    padding: 16,
    width: 1100,
    height: 1200
  });
});

test('comment_select', async ({ page, manual: screenshot }) => {
  await selectCommentForMove(page);
  await screenshot.capture('discussions/using_discussions/comment_select', {
    width: 1280,
    height: 1000
  });
});

test('move_items', async ({ page, manual: screenshot }) => {
  await selectCommentForMove(page);
  await screenshot.captureElement('discussions/using_discussions/move_items', '.topic-card', {
    width: 1100,
    height: 1600
  });
});

test('move_items_new_thread', async ({ page, manual: screenshot }) => {
  await openMoveItemsModal(page);
  await page.locator('.modal-launcher .v-card-actions .v-btn:first-of-type').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await page.locator('.discussion-form__title-input input').fill('Cafe return tracking follow-up')
  await page.locator('.discussion-form .ProseMirror').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('move-items-new-thread', [
    'Continue the detailed return tracking conversation in this focused discussion.',
    'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
    'Use the weekly totals to identify collection problems before the trial review.'
  ]))
  await screenshot.captureElement('discussions/using_discussions/move_items_new_thread', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('new_thread', async ({ page, manual: screenshot }) => {
  await openMoveItemsModal(page);
  await page.locator('.modal-launcher .v-card-actions .v-btn:first-of-type').click()
  await expect(page.locator('.discussion-form').first()).toBeVisible()
  await page.locator('.discussion-form__title-input input').fill('Cafe return tracking follow-up')
  await page.locator('.discussion-form .ProseMirror').evaluate((editor, html) => {
    editor.focus()
    editor.innerHTML = html
    editor.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }))
  }, richText.context('move-items-confirm', [
    'Continue the detailed return tracking conversation in this focused discussion.',
    'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
    'Use the weekly totals to identify collection problems before the trial review.'
  ]))
  await page.locator('.discussion-form__submit').click()
  await expect(page).toHaveURL(/\/d\//)
  await expect(page.locator('.context-panel__heading').first()).toBeVisible()
  await expectLabel(page.locator('.context-panel__heading'), 'Cafe return tracking follow-up')
  await page.locator('.discussion-form .dismiss-modal-button').click()
  await expectLabel(page.locator('.topic-page'), 'I can ask three cafes to track')
  await page.evaluate("document.querySelectorAll('.flash-root').forEach(el => el.remove())")
  await screenshot.capture('discussions/using_discussions/new_thread', {
    width: 1280,
    height: 1000
  });
});

test('copy_markdown_action', async ({ page, manual: screenshot }) => {
  await openCopyMarkdownDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--thread_markdown').first()).toBeVisible()
  await screenshot.capture('discussions/discussion_management/copy_markdown_action', {
    width: 1280,
    height: 1000,
    scrollSelector: '.topic-sidebar .action-dock__button--thread_markdown',
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--thread_markdown',
      padding: 16,
      radius: 16,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('copy_markdown_menu', async ({ page, manual: screenshot }) => {
  await openCopyMarkdownDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--thread_markdown').click()
  await expect(page.locator('.v-overlay--active .v-list').first()).toBeVisible()
  await expect(page.locator('.v-overlay--active .v-list .v-list-item:nth-child(2)').first()).toBeVisible()
  await screenshot.capture('discussions/discussion_management/copy_markdown_menu', {
    width: 1280,
    height: 1000,
    spotlight: {
      selector: '.v-overlay--active .v-list',
      padding: 16,
      radius: 16,
      opacity: 0.4,
      outlineWidth: 0
    }
  });
});

test('thread_delete', async ({ page, manual: screenshot }) => {
  await openThreadMenu(page);
  await page.locator('.v-overlay--active .action-dock__button--discard_thread').click()
  await expect(page.locator('.confirm-modal').first()).toBeVisible()
  await screenshot.captureElement('discussions/discussion_management/thread_delete', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});
