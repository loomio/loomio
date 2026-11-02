import { test, expect } from '../screenshotFixtures.mjs';

import richText from '../helpers/oatmilkRichText.mjs';

async function openGroup(page) {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.waitFor('.group-page');
  await page.waitFor('.topic-preview');
  await page.execute("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')");
  await page.waitFor('.manual-topic');
}

async function openThreadMenu(page) {
  await page.resizeWindow(1200, 1200);
  await openGroup(page);
  await page.click('.manual-topic .action-menu');
  await page.waitFor('.v-overlay--active .v-list');
}

async function openDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-page');
  await page.waitFor('.new-comment');
}

async function openCopyMarkdownDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_copy_markdown');
  await page.waitFor('.topic-page');
  await page.waitFor('.new-comment');
  await page.expectText('.topic-page', 'Run the six-week bottle trial with three cafes');
}

async function selectCommentForMove(page) {
  await openDiscussion(page);
  await page.click('.new-comment .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--move_event');
  await page.click('.v-overlay--active .action-dock__button--move_event');
  await page.waitFor('.discussion-fork-actions');
  await page.waitFor('.topic-item__is-forking');
  await page.click('.context-panel__heading');
}

async function openMoveItemsModal(page) {
  await selectCommentForMove(page);
  await page.click('.discussion-fork-actions__move');
  await page.waitFor('.modal-launcher .v-card');
  await page.expectText('.modal-launcher .v-card', 'Move items');
}

test('thread_management', async ({ lmo: page, manual: screenshot }) => {
  await openThreadMenu(page);
  await screenshot.captureRegion('discussions/discussion_management/thread_management', [
    '.manual-topic',
    '.v-overlay--active .v-list'
  ], {padding: 16, width: 1200, height: 1200});
});

test('permissions_manage_threads', async ({ lmo: page, manual: screenshot }) => {
  await openGroup(page);
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__permissions-tab');
  await page.waitFor('.group-form__members-can-edit-discussions');
  await page.execute("const input = document.querySelector('.group-form__members-can-edit-discussions input'); if (!input.checked) input.click()");
  await screenshot.captureElement('discussions/discussion_management/permissions_manage_threads', '.group-form__members-can-edit-discussions', {
    width: 1100,
    height: 1000
  });
});

test('pin_thread', async ({ lmo: page, manual: screenshot }) => {
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

test('thread_edit', async ({ lmo: page, manual: screenshot }) => {
  await openThreadMenu(page);
  await page.clickElement('.v-overlay--active .action-dock__button--edit_discussion');
  await page.waitFor('.discussion-form');
  await screenshot.captureElement('discussions/discussion_management/thread_edit', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('thread_move_group', async ({ lmo: page, manual: screenshot }) => {
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

test('move_thread_select', async ({ lmo: page, manual: screenshot }) => {
  await openThreadMenu(page);
  await page.clickElement('.v-overlay--active .action-dock__button--move_thread');
  await page.waitFor('.move-topic-form');
  await page.click('.move-topic-form__group-dropdown .v-field');
  await page.waitFor('.v-overlay--active .v-list');
  await screenshot.captureRegion('discussions/discussion_management/move_thread_select', [
    '.move-topic-form',
    '.v-overlay--active .v-list'
  ], {padding: 12, width: 1100, height: 1200});
});

test('comment_move', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.new-comment .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--move_event');
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

test('comment_select', async ({ lmo: page, manual: screenshot }) => {
  await selectCommentForMove(page);
  await screenshot.capture('discussions/using_discussions/comment_select', {
    width: 1280,
    height: 1000
  });
});

test('move_items', async ({ lmo: page, manual: screenshot }) => {
  await selectCommentForMove(page);
  await screenshot.captureElement('discussions/using_discussions/move_items', '.topic-card', {
    width: 1100,
    height: 1600
  });
});

test('move_items_new_thread', async ({ lmo: page, manual: screenshot }) => {
  await openMoveItemsModal(page);
  await page.click('.modal-launcher .v-card-actions .v-btn:first-of-type');
  await page.waitFor('.discussion-form');
  await page.fillIn('.discussion-form__title-input input', 'Cafe return tracking follow-up');
  await page.fillRichText('.discussion-form .ProseMirror', richText.context('move-items-new-thread', [
    'Continue the detailed return tracking conversation in this focused discussion.',
    'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
    'Use the weekly totals to identify collection problems before the trial review.'
  ]));
  await screenshot.captureElement('discussions/using_discussions/move_items_new_thread', '.discussion-form', {
    width: 1100,
    height: 1400
  });
});

test('new_thread', async ({ lmo: page, manual: screenshot }) => {
  await openMoveItemsModal(page);
  await page.click('.modal-launcher .v-card-actions .v-btn:first-of-type');
  await page.waitFor('.discussion-form');
  await page.fillIn('.discussion-form__title-input input', 'Cafe return tracking follow-up');
  await page.fillRichText('.discussion-form .ProseMirror', richText.context('move-items-confirm', [
    'Continue the detailed return tracking conversation in this focused discussion.',
    'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
    'Use the weekly totals to identify collection problems before the trial review.'
  ]));
  await page.click('.discussion-form__submit');
  await page.waitForUrlToContain('/d/');
  await page.waitFor('.context-panel__heading');
  await page.expectText('.context-panel__heading', 'Cafe return tracking follow-up');
  await page.click('.discussion-form .dismiss-modal-button');
  await page.pause(500);
  await page.expectText('.topic-page', 'I can ask three cafes to track');
  await page.execute("document.querySelectorAll('.flash-root').forEach(el => el.remove())");
  await screenshot.capture('discussions/using_discussions/new_thread', {
    width: 1280,
    height: 1000
  });
});

test('copy_markdown_action', async ({ lmo: page, manual: screenshot }) => {
  await openCopyMarkdownDiscussion(page);
  await page.waitFor('.topic-sidebar .action-dock__button--thread_markdown');
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

test('copy_markdown_menu', async ({ lmo: page, manual: screenshot }) => {
  await openCopyMarkdownDiscussion(page);
  await page.click('.topic-sidebar .action-dock__button--thread_markdown');
  await page.waitFor('.v-overlay--active .v-list');
  await page.waitFor('.v-overlay--active .v-list .v-list-item:nth-child(2)');
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

test('thread_delete', async ({ lmo: page, manual: screenshot }) => {
  await openThreadMenu(page);
  await page.clickElement('.v-overlay--active .action-dock__button--discard_thread');
  await page.waitFor('.confirm-modal');
  await screenshot.captureElement('discussions/discussion_management/thread_delete', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});
