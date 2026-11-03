import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { groupAction } from '../helpers/groups.mjs';
import { comment, itemAction } from '../helpers/threads.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

const activeMenu = '.v-overlay--active .v-list';

const topicPreview = page => page.locator('.topic-preview', { hasText: 'Returnable bottles for cafe customers' });

// Capture regions are CSS selectors, so mark the thread's preview with a class.
// A re-render drops the class, so mark it after the page has settled.
async function markTopic(page) {
  await topicPreview(page).evaluate(element => element.classList.add('manual-topic'));
}

async function openGroup(page) {
  await page.goto('/dev/setup_manual_oatmilk_group');
  await markTopic(page);
}

async function openThreadMenu(page) {
  await page.setViewportSize({ width: 1200, height: 1200 });
  await page.goto('/dev/setup_manual_oatmilk_group');
  await topicPreview(page).locator('.action-menu--btn').click();
  await expect(page.locator(activeMenu)).toBeVisible();
  await markTopic(page);
}

const theComment = page => comment(page, 'I can ask three cafes to track');

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion');
  await expect(theComment(page)).toBeVisible();
}

async function openCopyMarkdownDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_copy_markdown');
  await expect(theComment(page)).toBeVisible();
  await expectLabel(page.locator('.topic-page'), 'Run the six-week bottle trial with three cafes');
}

async function selectCommentForMove(page) {
  await openDiscussion(page);
  await itemAction(page, theComment(page), 'move_event');
  await expect(page.locator('.discussion-fork-actions')).toBeVisible();
  await expect(page.locator('.topic-item__is-forking.v-selection-control--dirty')).toBeVisible();
  await page.locator('.context-panel__heading').click();
}

async function openMoveItemsModal(page) {
  await selectCommentForMove(page);
  await page.locator('.discussion-fork-actions__move').click();
  await expectLabel(page.locator('.move-comments-modal'), 'Move items');
}

async function startNewThreadFromMovedItems(page, key) {
  await openMoveItemsModal(page);
  await page.locator('.move-comments-modal__new-thread').click();
  const form = page.locator('.discussion-form');
  await form.locator('.discussion-form__title-input input').fill('Cafe return tracking follow-up');
  await editor(form).evaluate((element, html) => {
    element.focus();
    element.innerHTML = html;
    element.dispatchEvent(new InputEvent('input', { bubbles: true, inputType: 'insertText' }));
  }, richText.context(key, [
    'Continue the detailed return tracking conversation in this focused discussion.',
    'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
    'Use the weekly totals to identify collection problems before the trial review.'
  ]));
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
  await groupAction(page, 'edit_group');
  await page.locator('.group-form__permissions-tab').click();
  await page.locator('.group-form__members-can-edit-discussions input').check();
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
  await page.locator('.v-overlay--active .action-dock__button--edit_discussion').click();
  await expect(page.locator('.discussion-form')).toBeVisible();
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
  await page.locator('.v-overlay--active .action-dock__button--move_thread').click();
  await page.locator('.move-topic-form__group-dropdown .v-field').click();
  await expect(page.locator('.v-overlay--active .v-list[role="listbox"]')).toBeVisible();
  await screenshot.captureRegion('discussions/discussion_management/move_thread_select', [
    '.move-topic-form',
    '.v-overlay--active .v-list'
  ], {padding: 12, width: 1100, height: 1200});
});

test('comment_move', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await theComment(page).locator('.action-menu--btn').click();
  await expect(page.locator('.v-overlay--active .action-dock__button--move_event')).toBeVisible();
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
  await startNewThreadFromMovedItems(page, 'move-items-new-thread');
  await screenshot.captureElement('discussions/using_discussions/move_items_new_thread', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('new_thread', async ({ page, manual: screenshot }) => {
  await startNewThreadFromMovedItems(page, 'move-items-confirm');
  await page.locator('.discussion-form__submit').click();
  await expect(page).toHaveURL(/\/d\//);
  await expectLabel(page.locator('.context-panel__heading'), 'Cafe return tracking follow-up');
  await page.locator('.discussion-form .dismiss-modal-button').click();
  await expectLabel(page.locator('.topic-page'), 'I can ask three cafes to track');
  // The capture hides flash messages.
  await screenshot.capture('discussions/using_discussions/new_thread', {
    width: 1280,
    height: 1000
  });
});

test('copy_markdown_action', async ({ page, manual: screenshot }) => {
  await openCopyMarkdownDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--thread_markdown')).toBeVisible();
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
  await page.locator('.topic-sidebar .action-dock__button--thread_markdown').click();
  // Copy and download.
  await expect(page.locator(`${activeMenu} .v-list-item`)).toHaveCount(2);
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
  await page.locator('.v-overlay--active .action-dock__button--discard_thread').click();
  await expect(page.locator('.confirm-modal')).toBeVisible();
  await screenshot.captureElement('discussions/discussion_management/thread_delete', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});
