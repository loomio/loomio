const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.strand-page');
  page.expectText('.strand-page', 'Returnable bottles for cafe customers');
  page.waitFor('.comment-form .ProseMirror');
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
    screenshot.captureElement('discussions/using_discussions/thread_context', '.strand-new-discussion', {
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
    screenshot.captureElement('discussions/using_discussions/thread_context_edit', '.discussion-form .lmo-textarea', {
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

    openDiscussion(page);
    page.waitFor('.new-comment');
    screenshot.captureElement('discussions/using_discussions/thread_unread_comments', '.new-comment', {
      width: 1100,
      height: 1000
    });
  },

  'comment': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.fillIn('.comment-form .ProseMirror', 'I can help document the cleaning time during the trial.');
    screenshot.captureRegion('discussions/using_discussions/comment', [
      '.comment-form .lmo-textarea',
      '.comment-form__submit-button'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'reaction': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.waitFor('.new-comment .emoji-picker__toggle');
    page.execute("document.querySelector('.new-comment .action-dock').style.marginLeft = '20px'");
    screenshot.captureElement('discussions/using_discussions/reaction', '.new-comment', {
      spotlight: {
        selector: '.new-comment .emoji-picker__toggle',
        padding: 12,
        radius: 14
      },
      width: 1100,
      height: 1000
    });
  },

  'comment_reply': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    openDiscussion(page);
    page.click('.new-comment .action-dock__button--reply_to_comment');
    page.waitFor('.reply-form .comment-form');
    screenshot.captureRegion('discussions/using_discussions/comment_reply', [
      '.new-comment',
      '.reply-form .comment-form'
    ], {padding: 12, width: 1100, height: 1400});
  },

  'comment_translate': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);

    page.loadPath('setup_manual_oatmilk_translated_comment');
    page.waitFor('.strand-page');
    page.waitFor('.new-comment .action-dock__button--translate_comment');
    screenshot.captureElement('discussions/using_discussions/comment_translate', '.new-comment', {
      spotlight: {
        selector: '.new-comment .action-dock__button--translate_comment',
        padding: 12,
        radius: 14
      },
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
    screenshot.captureElement('discussions/using_discussions/comment_translated', '.new-comment', {
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
    screenshot.captureElement('discussions/using_discussions/comment_show_edits', '.manual-own-comment', {
      spotlight: {
        selector: '.manual-own-comment .action-dock__button--show_history',
        padding: 12,
        radius: 14
      },
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
      padding: 12,
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
    screenshot.captureElement('discussions/using_discussions/permissions_delete_comment', '.group-form__members-can-delete-comments', {
      width: 1100,
      height: 1000
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
