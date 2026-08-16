const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.strand-page');
  page.expectText('.strand-page', 'Returnable bottles for cafe customers');
  page.waitFor('.comment-form .ProseMirror');
}

function openCommentDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_comment_discussion');
  page.waitFor('.strand-page');
  page.expectText('.strand-page', 'Improve the cafe bottle collection process');
  page.expectCount('.new-comment', 5);
  page.waitFor('#add-comment .comment-form .ProseMirror');
  page.execute("const comments = Array.from(document.querySelectorAll('.new-comment')); comments[0].classList.add('manual-comment-first'); comments[2].classList.add('manual-comment-reply-target'); comments.at(-1).classList.add('manual-comment-last')");
  page.waitFor('.manual-comment-last');
}

function postOwnComment(page, body) {
  page.fillIn('.comment-form .ProseMirror', body);
  page.click('.comment-form__submit-button');
  page.pause(800);
  page.expectText('.strand-page', body);
  page.execute("Array.from(document.querySelectorAll('.new-comment')).find(el => el.textContent.includes('I can document the cleaning time')).classList.add('manual-own-comment')");
  page.waitFor('.manual-own-comment');
}

function editOwnComment(page) {
  postOwnComment(page, 'I can document the cleaning time during the trial.');
  page.click('.manual-own-comment .action-dock__button--edit_comment');
  page.waitFor('.edit-comment-form');
}

function discardFirstComment(page) {
  openDiscussion(page);
  page.click('.new-comment .action-menu');
  page.waitFor('.v-overlay--active .action-dock__button--discard_comment');
  page.click('.v-overlay--active .action-dock__button--discard_comment');
  page.waitFor('.strand-item__removed');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'thread_navigation': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    screenshot.capture('discussions/using_discussions/thread_navigation', {
      width: 1280,
      height: 1000
    });
  },

  'thread_context': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    screenshot.captureRegion('discussions/using_discussions/thread_context', ['.strand-new-discussion'], {
      padding: 32,
      width: 1100,
      height: 1000
    });
  },

  'thread_context_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.context-panel .action-dock__button--edit_thread');
    page.waitFor('.discussion-form');
    screenshot.captureRegion('discussions/using_discussions/thread_context_edit', ['.discussion-form .lmo-textarea'], {
      padding: 32,
      width: 1100,
      height: 1000
    });
  },

  'thread_timeline': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_thread_navigation');
    page.waitFor('.strand-page');
    page.waitFor('.thread-sidebar');
    page.expectText('.thread-sidebar', 'New to you');
    screenshot.capture('discussions/using_discussions/thread_timeline_1', {
      spotlight: {
        selector: '.thread-sidebar',
        padding: 0,
        radius: 0
      },
      width: 1280,
      height: 1000
    });
  },

  'thread_unread_comments': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openCommentDiscussion(page);
    screenshot.captureRegion('discussions/using_discussions/thread_unread_comments', [
      '.manual-comment-first',
      '.manual-comment-last'
    ], {
      padding: 32,
      spotlight: {selectors: ['.manual-comment-first', '.manual-comment-last'], padding: 12, radius: 14},
      width: 1100,
      height: 1800
    });
  },

  'comment': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.resizeWindow(1100, 1200);
    openCommentDiscussion(page);
    const draft = 'I can help document the cleaning time during the trial.';
    page.clickElement('#add-comment .comment-form .ProseMirror');
    page.fillIn('#add-comment .comment-form .ProseMirror', draft);
    page.expectText('#add-comment .comment-form .ProseMirror', draft);
    test.pause(500);
    screenshot.captureRegion('discussions/using_discussions/comment', [
      '.manual-comment-last',
      '#add-comment .comment-form'
    ], {
      padding: 32,
      width: 1100,
      height: 1200,
      spotlight: {selector: '#add-comment .comment-form', padding: 12, radius: 14}
    });
  },

  'reaction': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.new-comment .emoji-picker__toggle');
    page.click('.new-comment .emoji-picker__toggle');
    page.waitFor('.v-overlay--active .emoji-picker');
    screenshot.captureRegion('discussions/using_discussions/reaction', [
      '.new-comment',
      '.v-overlay--active .emoji-picker'
    ], {
      padding: 24,
      width: 1100,
      height: 1400,
      spotlight: {selector: '.new-comment .emoji-picker__toggle', padding: 10, radius: 12}
    });
  },

  'comment_reply': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openCommentDiscussion(page);
    page.click('.manual-comment-reply-target .action-dock__button--reply_to_comment');
    page.waitFor('.reply-form .comment-form');
    screenshot.captureRegion('discussions/using_discussions/comment_reply', [
      '.manual-comment-reply-target',
      '.reply-form .comment-form'
    ], {
      padding: 32,
      width: 1100,
      height: 1200,
      spotlight: {selector: '.reply-form .comment-form', padding: 12, radius: 14}
    });
  },

  'comment_translate': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_translated_comment');
    page.waitFor('.strand-page');
    page.waitFor('.new-comment .action-dock__button--translate_comment');
    screenshot.captureRegion('discussions/using_discussions/comment_translate', ['.new-comment'], {
      spotlight: {
        selector: '.new-comment .action-dock__button--translate_comment',
        padding: 12,
        radius: 14
      },
      padding: 32,
      width: 1100,
      height: 1000
    });
  },

  'comment_translated': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_translated_comment');
    page.waitFor('.strand-page');
    page.click('.new-comment .action-dock__button--translate_comment');
    page.waitFor('.new-comment .action-dock__button--untranslate_comment');
    page.expectText('.new-comment', 'I can ask three cafes to track');
    screenshot.captureRegion('discussions/using_discussions/comment_translated', ['.new-comment'], {
      padding: 32,
      width: 1100,
      height: 1000
    });
  },

  'comment_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    editOwnComment(page);
    screenshot.captureElement('discussions/using_discussions/comment_edit', '.edit-comment-form', {
      width: 1100,
      height: 1200
    });
  },

  'comment_show_edits': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    editOwnComment(page);
    page.fillIn('.edit-comment-form .ProseMirror', 'I can document the bottle cleaning time during the trial.');
    page.click('.edit-comment-form .comment-form__submit-button');
    page.waitFor('.manual-own-comment .action-dock__button--show_history');
    screenshot.captureRegion('discussions/using_discussions/comment_show_edits', ['.manual-own-comment'], {
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
  },

  'comment_edits': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    editOwnComment(page);
    page.fillIn('.edit-comment-form .ProseMirror', 'I can document the bottle cleaning time during the trial.');
    page.click('.edit-comment-form .comment-form__submit-button');
    page.waitFor('.manual-own-comment .action-dock__button--show_history');
    page.click('.manual-own-comment .action-dock__button--show_history');
    page.waitFor('.revision-history-modal');
    screenshot.captureElement('discussions/using_discussions/comment_edits', '.revision-history-modal', {
      width: 1100,
      height: 1200
    });
  },

  'comment_copy_link': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.new-comment .action-menu');
    page.waitFor('.action-dock__button--copy_url');
    screenshot.captureRegion('discussions/using_discussions/comment_copy_link', [
      '.new-comment',
      '.v-overlay--active .v-list'
    ], {
      padding: 32,
      width: 1100,
      height: 1200
    });
  },

  'comment_discard': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.new-comment .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--discard_comment');
    screenshot.captureRegion('discussions/using_discussions/comment_discard', [
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
  },

  'comment_restore': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    discardFirstComment(page);
    page.click('.strand-item__removed .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--undiscard_comment');
    screenshot.captureRegion('discussions/using_discussions/comment_restore', [
      '.strand-item__removed',
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
  },

  'permissions_delete_comment': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_group');
    page.waitFor('.group-page');
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--edit_group');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.click('.group-form__permissions-tab');
    page.waitFor('.group-form__members-can-delete-comments');
    page.execute("const input = document.querySelector('.group-form__members-can-delete-comments input'); if (!input.checked) input.click()");
    screenshot.captureElement('discussions/using_discussions/permissions_delete_comment', '.group-form', {
      spotlight: {selector: '.group-form__members-can-delete-comments', padding: 10, radius: 12},
      width: 1100,
      height: 1600
    });
  },

  'comment_delete': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    discardFirstComment(page);
    page.click('.strand-item__removed .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--delete_comment');
    screenshot.captureRegion('discussions/using_discussions/comment_delete', [
      '.strand-item__removed',
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
  },

  'comment_delete_message': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    discardFirstComment(page);
    page.click('.strand-item__removed .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--delete_comment');
    page.click('.v-overlay--active .action-dock__button--delete_comment');
    page.waitFor('.confirm-modal');
    screenshot.captureElement('discussions/using_discussions/comment_delete_message', '.confirm-modal', {
      width: 1100,
      height: 1000
    });
  },

  'thread_display': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.thread-sidebar .action-dock__button--thread_settings');
    screenshot.capture('discussions/using_discussions/thread_display', {
      spotlight: {
        selector: '.thread-sidebar .action-dock__button--thread_settings',
        padding: 10,
        radius: 12
      },
      scrollSelector: '.thread-sidebar .action-dock__button--thread_settings',
      width: 1280,
      height: 1000
    });
  },

  'thread_layout_options': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.thread-sidebar .action-dock__button--thread_settings');
    page.waitFor('.thread-arrangement-form');
    screenshot.captureElement('discussions/using_discussions/thread_layout_options', '.thread-arrangement-form', {
      width: 1100,
      height: 1200
    });
  },

  'thread_admin': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    screenshot.capture('discussions/using_discussions/thread_admin', {
      spotlight: {
        selector: '.thread-sidebar .v-list:last-child',
        padding: 8,
        radius: 12
      },
      scrollSelector: '.thread-sidebar .v-list:last-child',
      width: 1280,
      height: 1000
    });
  },

  'thread_print_thread': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.thread-sidebar .action-dock__button--export_thread');
    screenshot.capture('discussions/using_discussions/thread_print_thread', {
      spotlight: {
        selector: '.thread-sidebar .action-dock__button--export_thread',
        padding: 10,
        radius: 12
      },
      scrollSelector: '.thread-sidebar .action-dock__button--export_thread',
      width: 1280,
      height: 1000
    });
  }
};
