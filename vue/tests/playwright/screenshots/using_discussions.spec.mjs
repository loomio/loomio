import { test, expect, expectLabel } from '../screenshotFixtures.mjs';
import { editor } from '../helpers/editor.mjs';
import { comment, commentForm, postComment } from '../helpers/threads.mjs';

// Captures take CSS selectors, which cannot match text or position, so mark
// the elements a capture needs.
const mark = (locator, className) => locator.evaluate((element, name) => element.classList.add(name), className);
// The first comment, which captures of '.new-comment' show.
const firstComment = page => page.locator('.new-comment').first();

async function openDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expectLabel(page.locator('.topic-page'), 'Returnable bottles for cafe customers')
  await expect(editor(commentForm(page))).toBeVisible()
}

async function openCommentDiscussion(page) {
  await page.goto('/dev/setup_manual_oatmilk_comment_discussion')
  await expectLabel(page.locator('.topic-page'), 'Improve the cafe bottle collection process')
  const comments = page.locator('.new-comment')
  await expect(comments).toHaveCount(5)
  await expect(editor(commentForm(page))).toBeVisible()
  await mark(comments.first(), 'manual-comment-first')
  await mark(comments.nth(2), 'manual-comment-reply-target')
  await mark(comments.last(), 'manual-comment-last')
}

async function postOwnComment(page, body) {
  await postComment(page, body)
  await expectLabel(page.locator('.topic-page'), body)
  await mark(comment(page, body), 'manual-own-comment')
}

async function editOwnComment(page) {
  await postOwnComment(page, 'I can document the cleaning time during the trial.');
  await page.locator('.manual-own-comment .action-dock__button--edit_comment').click()
  await expect(editor(page.locator('.edit-comment-form'))).toBeVisible()
}

async function discardFirstComment(page) {
  await openDiscussion(page);
  await firstComment(page).locator('.action-menu').click()
  await page.locator('.v-overlay--active .action-dock__button--discard_comment').click()
  await expect(page.locator('.topic-item__removed')).toBeVisible()
}

test('thread_navigation', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.capture('discussions/using_discussions/thread_navigation', {
    width: 1280,
    height: 1000
  });
});

test('thread_context', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await screenshot.captureRegion('discussions/using_discussions/thread_context', ['.topic-new-discussion'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('thread_context_edit', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await page.locator('.context-panel .action-dock__button--edit_thread').click()
  await expect(editor(page.locator('.discussion-form'))).toBeVisible()
  await screenshot.captureRegion('discussions/using_discussions/thread_context_edit', ['.discussion-form .lmo-textarea'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('thread_timeline', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_thread_navigation')
  await expectLabel(page.locator('.topic-sidebar'), 'New to you')
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

test('thread_unread_comments', async ({ page, manual: screenshot }) => {
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

test('comment', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1100, height: 1200 })
  await openCommentDiscussion(page);
  const draft = 'I can help document the cleaning time during the trial.';
  const input = editor(commentForm(page))
  await input.click()
  await input.fill(draft)
  await expectLabel(input, draft)
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

test('reaction', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await firstComment(page).locator('.emoji-picker__toggle').click()
  await expect(page.locator('.v-overlay--active .emoji-picker')).toBeVisible()
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

test('comment_reply', async ({ page, manual: screenshot }) => {
  await openCommentDiscussion(page);
  await page.locator('.manual-comment-reply-target .action-dock__button--reply_to_comment').click()
  await expect(editor(page.locator('.reply-form .comment-form'))).toBeVisible()
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

test('comment_translate', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_translated_comment')
  await expect(firstComment(page).locator('.action-dock__button--translate_comment')).toBeVisible()
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

test('comment_translated', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_translated_comment')
  await firstComment(page).locator('.action-dock__button--translate_comment').click()
  await expect(firstComment(page).locator('.action-dock__button--untranslate_comment')).toBeVisible()
  await expectLabel(page.locator('.new-comment'), 'I can ask three cafes to track')
  await screenshot.captureRegion('discussions/using_discussions/comment_translated', ['.new-comment'], {
    padding: 32,
    width: 1100,
    height: 1000
  });
});

test('comment_edit', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await editOwnComment(page);
  await screenshot.captureElement('discussions/using_discussions/comment_edit', '.edit-comment-form', {
    width: 1100,
    height: 1200
  });
});

test('comment_show_edits', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await editOwnComment(page);
  await editor(page.locator('.edit-comment-form')).fill('I can document the bottle cleaning time during the trial.')
  await page.locator('.edit-comment-form .comment-form__submit-button').click()
  await expect(page.locator('.manual-own-comment .action-dock__button--show_history')).toBeVisible()
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

test('comment_edits', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await editOwnComment(page);
  await editor(page.locator('.edit-comment-form')).fill('I can document the bottle cleaning time during the trial.')
  await page.locator('.edit-comment-form .comment-form__submit-button').click()
  await page.locator('.manual-own-comment .action-dock__button--show_history').click()
  await expect(page.locator('.revision-history-modal')).toBeVisible()
  await screenshot.captureElement('discussions/using_discussions/comment_edits', '.revision-history-modal', {
    width: 1100,
    height: 1200
  });
});

test('comment_copy_link', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await firstComment(page).locator('.action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--copy_url')).toBeVisible()
  await screenshot.captureRegion('discussions/using_discussions/comment_copy_link', [
    '.new-comment',
    '.v-overlay--active .v-list'
  ], {
    padding: 32,
    width: 1100,
    height: 1200
  });
});

test('comment_discard', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await firstComment(page).locator('.action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--discard_comment')).toBeVisible()
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

test('comment_restore', async ({ page, manual: screenshot }) => {
  await discardFirstComment(page);
  await page.locator('.topic-item__removed .action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--undiscard_comment')).toBeVisible()
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

test('permissions_delete_comment', async ({ page, manual: screenshot }) => {
  await page.goto('/dev/setup_manual_oatmilk_group')
  await page.locator('.group-page__actions .action-menu--btn').click()
  await page.locator('.v-overlay--active .action-dock__button--edit_group').click()
  await page.locator('.group-form__permissions-tab').click()
  await expect(page.locator('.group-form__members-can-delete-comments')).toBeVisible()
  // Tick it without moving the mouse, so the checkbox shows no hover state.
  await page.locator('.group-form__members-can-delete-comments input').evaluate(input => { if (!input.checked) input.click(); })
  await expect(page.locator('.group-form__members-can-delete-comments input')).toBeChecked()
  await screenshot.captureElement('discussions/using_discussions/permissions_delete_comment', '.group-form', {
    spotlight: {selector: '.group-form__members-can-delete-comments', padding: 10, radius: 12},
    width: 1100,
    height: 1600
  });
});

test('comment_delete', async ({ page, manual: screenshot }) => {
  await discardFirstComment(page);
  await page.locator('.topic-item__removed .action-menu').click()
  await expect(page.locator('.v-overlay--active .action-dock__button--delete_comment')).toBeVisible()
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

test('comment_delete_message', async ({ page, manual: screenshot }) => {
  await discardFirstComment(page);
  await page.locator('.topic-item__removed .action-menu').click()
  await page.locator('.v-overlay--active .action-dock__button--delete_comment').click()
  await expect(page.locator('.confirm-modal')).toBeVisible()
  await screenshot.captureElement('discussions/using_discussions/comment_delete_message', '.confirm-modal', {
    width: 1100,
    height: 1000
  });
});

test('thread_display', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--thread_settings')).toBeVisible()
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

test('thread_layout_options', async ({ page, manual: screenshot }) => {
  await page.setViewportSize({ width: 1100, height: 1200 })
  await openDiscussion(page);
  await page.locator('.topic-sidebar .action-dock__button--thread_settings').click()
  const settings = page.locator('.topic-arrangement-form')
  await expect(settings.locator('.topic-settings__attachments-admin-only')).toBeVisible()
  await expect(settings.locator('.topic-arrangement-form__help')).toHaveAttribute('href', /\/user_manual\/discussions\/using_discussions#thread-settings/)
  await expect(settings.locator('.topic-settings__single-poll input')).not.toBeChecked()
  await screenshot.captureElement('discussions/using_discussions/thread_layout_options', '.topic-arrangement-form', {
    width: 1100,
    height: 1200
  });
});

test('thread_admin', async ({ page, manual: screenshot }) => {
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

test('thread_print_thread', async ({ page, manual: screenshot }) => {
  await openDiscussion(page);
  await expect(page.locator('.topic-sidebar .action-dock__button--export_thread')).toBeVisible()
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
