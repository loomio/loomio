import { test, expect } from '../screenshotFixtures.mjs';

async function openDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_discussion');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Returnable bottles for cafe customers');
  await page.waitFor('.comment-form .ProseMirror');
}

async function openCommentDiscussion(page) {
  await page.loadPath('setup_manual_oatmilk_comment_discussion');
  await page.waitFor('.topic-page');
  await page.expectText('.topic-page', 'Improve the cafe bottle collection process');
  await page.expectCount('.new-comment', 5);
  await page.waitFor('#add-comment .comment-form .ProseMirror');
  await page.execute("const comments = Array.from(document.querySelectorAll('.new-comment')); comments[0].classList.add('manual-comment-first'); comments[2].classList.add('manual-comment-reply-target'); comments.at(-1).classList.add('manual-comment-last')");
  await page.waitFor('.manual-comment-last');
}

async function postOwnComment(page, body) {
  await page.fillIn('.comment-form .ProseMirror', body);
  await page.click('.comment-form__submit-button');
  await page.pause(800);
  await page.expectText('.topic-page', body);
  await page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('I can document the cleaning time')).classList.add('manual-own-comment')");
  await page.waitFor('.manual-own-comment');
}

async function editOwnComment(page) {
  await postOwnComment(page, 'I can document the cleaning time during the trial.');
  await page.click('.manual-own-comment .action-dock__button--edit_comment');
  await page.waitFor('.edit-comment-form');
}

async function discardFirstComment(page) {
  await openDiscussion(page);
  await page.click('.new-comment .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--discard_comment');
  await page.click('.v-overlay--active .action-dock__button--discard_comment');
  await page.waitFor('.topic-item__removed');
}

test('thread_navigation', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.capture('discussions/using_discussions/thread_navigation', {
    width: 1280,
    height: 1000
  });
});

test('thread_context', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.captureRegion('discussions/using_discussions/thread_context', ['.topic-new-discussion'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('thread_context_edit', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.context-panel .action-dock__button--edit_thread');
  await page.waitFor('.discussion-form');
  await screenshot.captureRegion('discussions/using_discussions/thread_context_edit', ['.discussion-form .lmo-textarea'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('thread_timeline', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_thread_navigation');
  await page.waitFor('.topic-page');
  await page.waitFor('.topic-sidebar');
  await page.expectText('.topic-sidebar', 'New to you');
  await screenshot.capture('discussions/using_discussions/thread_timeline_1', {
    spotlight: {
      selector: '.topic-sidebar',
      padding: 0,
      radius: 0
    },
    width: 1280,
    height: 1000
  });
});

test('thread_unread_comments', async ({ lmo: page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await screenshot.captureRegion('discussions/using_discussions/thread_unread_comments', [
    '.manual-comment-first',
    '.manual-comment-last'
  ], {
    padding: 32,
    spotlight: {selectors: ['.manual-comment-first', '.manual-comment-last'], padding: 12, radius: 14},
    width: 1100,
    height: 1800
  });
});

test('comment', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1100, 1200);
  await openCommentDiscussion(page);
  const draft = 'I can help document the cleaning time during the trial.';
  await page.clickElement('#add-comment .comment-form .ProseMirror');
  await page.fillIn('#add-comment .comment-form .ProseMirror', draft);
  await page.expectText('#add-comment .comment-form .ProseMirror', draft);
  await page.pause(500);
  await screenshot.captureRegion('discussions/using_discussions/comment', [
    '.manual-comment-last',
    '#add-comment .comment-form'
  ], {
    padding: 32,
    width: 1100,
    height: 1200,
    spotlight: {selector: '#add-comment .comment-form', padding: 12, radius: 14}
  });
});

test('reaction', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.waitFor('.new-comment .emoji-picker__toggle');
  await page.click('.new-comment .emoji-picker__toggle');
  await page.waitFor('.v-overlay--active .emoji-picker');
  await screenshot.captureRegion('discussions/using_discussions/reaction', [
    '.new-comment',
    '.v-overlay--active .emoji-picker'
  ], {
    padding: 24,
    width: 1100,
    height: 1400,
    spotlight: {selector: '.new-comment .emoji-picker__toggle', padding: 10, radius: 12}
  });
});

test('comment_reply', async ({ lmo: page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await page.click('.manual-comment-reply-target .action-dock__button--reply_to_comment');
  await page.waitFor('.reply-form .comment-form');
  await screenshot.captureRegion('discussions/using_discussions/comment_reply', [
    '.manual-comment-reply-target',
    '.reply-form .comment-form'
  ], {
    padding: 32,
    width: 1100,
    height: 1200,
    spotlight: {selector: '.reply-form .comment-form', padding: 12, radius: 14}
  });
});

test('comment_translate', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_translated_comment');
  await page.waitFor('.topic-page');
  await page.waitFor('.new-comment .action-dock__button--translate_comment');
  await screenshot.captureRegion('discussions/using_discussions/comment_translate', ['.new-comment'], {
    spotlight: {
      selector: '.new-comment .action-dock__button--translate_comment',
      padding: 12,
      radius: 14
    },
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('comment_translated', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_translated_comment');
  await page.waitFor('.topic-page');
  await page.click('.new-comment .action-dock__button--translate_comment');
  await page.waitFor('.new-comment .action-dock__button--untranslate_comment');
  await page.expectText('.new-comment', 'I can ask three cafes to track');
  await screenshot.captureRegion('discussions/using_discussions/comment_translated', ['.new-comment'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('comment_edit', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await editOwnComment(page);
  await screenshot.captureElement('discussions/using_discussions/comment_edit', '.edit-comment-form', {
    width: 1100,
    height: 1200
  });
});

test('comment_show_edits', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await editOwnComment(page);
  await page.fillIn('.edit-comment-form .ProseMirror', 'I can document the bottle cleaning time during the trial.');
  await page.click('.edit-comment-form .comment-form__submit-button');
  await page.waitFor('.manual-own-comment .action-dock__button--show_history');
  await screenshot.captureRegion('discussions/using_discussions/comment_show_edits', ['.manual-own-comment'], {
    scrollSelector: '.manual-own-comment',
    spotlight: {
      selector: '.manual-own-comment .action-dock__button--show_history',
      padding: 12,
      radius: 14
    },
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('comment_edits', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await editOwnComment(page);
  await page.fillIn('.edit-comment-form .ProseMirror', 'I can document the bottle cleaning time during the trial.');
  await page.click('.edit-comment-form .comment-form__submit-button');
  await page.waitFor('.manual-own-comment .action-dock__button--show_history');
  await page.click('.manual-own-comment .action-dock__button--show_history');
  await page.waitFor('.revision-history-modal');
  await screenshot.captureElement('discussions/using_discussions/comment_edits', '.revision-history-modal', {
    width: 1100,
    height: 1200
  });
});

test('comment_copy_link', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.new-comment .action-menu');
  await page.waitFor('.action-dock__button--copy_url');
  await screenshot.captureRegion('discussions/using_discussions/comment_copy_link', [
    '.new-comment',
    '.v-overlay--active .v-list'
  ], {
    padding: 32,
    width: 1100,
    height: 1200
  });
});

test('comment_discard', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.click('.new-comment .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--discard_comment');
  await screenshot.captureRegion('discussions/using_discussions/comment_discard', [
    '.new-comment',
    '.v-overlay--active .v-list'
  ], {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--discard_comment',
      padding: 8,
      radius: 12
    },
    padding: 16,
    width: 1100,
    height: 1200
  });
});

test('comment_restore', async ({ lmo: page, manual: screenshot }) => {
  await discardFirstComment(page);
  await page.click('.topic-item__removed .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--undiscard_comment');
  await screenshot.captureRegion('discussions/using_discussions/comment_restore', [
    '.topic-item__removed',
    '.v-overlay--active .v-list'
  ], {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--undiscard_comment',
      padding: 8,
      radius: 12
    },
    padding: 16,
    width: 1100,
    height: 1000
  });
});

test('permissions_delete_comment', async ({ lmo: page, manual: screenshot }) => {
  await page.loadPath('setup_manual_oatmilk_group');
  await page.waitFor('.group-page');
  await page.click('.group-page .action-menu--btn');
  await page.waitFor('.v-overlay .action-dock__button--edit_group');
  await page.click('.v-overlay .action-dock__button--edit_group');
  await page.waitFor('.group-form');
  await page.click('.group-form__permissions-tab');
  await page.waitFor('.group-form__members-can-delete-comments');
  await page.execute("const input = document.querySelector('.group-form__members-can-delete-comments input'); if (!input.checked) input.click()");
  await screenshot.captureElement('discussions/using_discussions/permissions_delete_comment', '.group-form', {
    spotlight: {selector: '.group-form__members-can-delete-comments', padding: 10, radius: 12},
    width: 1100,
    height: 1600
  });
});

test('comment_delete', async ({ lmo: page, manual: screenshot }) => {
  await discardFirstComment(page);
  await page.click('.topic-item__removed .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--delete_comment');
  await screenshot.captureRegion('discussions/using_discussions/comment_delete', [
    '.topic-item__removed',
    '.v-overlay--active .v-list'
  ], {
    spotlight: {
      selector: '.v-overlay--active .action-dock__button--delete_comment',
      padding: 8,
      radius: 12
    },
    padding: 16,
    width: 1100,
    height: 1000
  });
});

test('comment_delete_message', async ({ lmo: page, manual: screenshot }) => {
  await discardFirstComment(page);
  await page.click('.topic-item__removed .action-menu');
  await page.waitFor('.v-overlay--active .action-dock__button--delete_comment');
  await page.click('.v-overlay--active .action-dock__button--delete_comment');
  await page.waitFor('.confirm-modal');
  await screenshot.captureElement('discussions/using_discussions/comment_delete_message', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});

test('thread_display', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.waitFor('.topic-sidebar .action-dock__button--thread_settings');
  await screenshot.capture('discussions/using_discussions/thread_display', {
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--thread_settings',
      padding: 10,
      radius: 12
    },
    scrollSelector: '.topic-sidebar .action-dock__button--thread_settings',
    width: 1280,
    height: 1000
  });
});

test('thread_layout_options', async ({ lmo: page, manual: screenshot }) => {
  await page.resizeWindow(1100, 1200);
  await openDiscussion(page);
  await page.click('.topic-sidebar .action-dock__button--thread_settings');
  await page.waitFor('.topic-arrangement-form');
  await page.expectElement('.topic-settings__attachments-admin-only');
  await page.expectElement('.topic-arrangement-form .v-card-item__append .help-link');
  await page.expectAttribute('.topic-arrangement-form .v-card-item__append .help-link', 'href', '/user_manual/discussions/using_discussions#thread-settings');
  await page.expectNotChecked('.topic-arrangement-form .topic-settings__single-poll input');
  await screenshot.captureElement('discussions/using_discussions/thread_layout_options', '.topic-arrangement-form', {
    width: 1100,
    height: 1200
  });
});

test('thread_admin', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.capture('discussions/using_discussions/thread_admin', {
    spotlight: {
      selector: '.topic-sidebar .v-list:last-child',
      padding: 8,
      radius: 12
    },
    scrollSelector: '.topic-sidebar .v-list:last-child',
    width: 1280,
    height: 1000
  });
});

test('thread_print_thread', async ({ lmo: page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.waitFor('.topic-sidebar .action-dock__button--export_thread');
  await screenshot.capture('discussions/using_discussions/thread_print_thread', {
    spotlight: {
      selector: '.topic-sidebar .action-dock__button--export_thread',
      padding: 10,
      radius: 12
    },
    scrollSelector: '.topic-sidebar .action-dock__button--export_thread',
    width: 1280,
    height: 1000
  });
});
