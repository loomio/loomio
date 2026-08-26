const pageHelper = require('../helpers/pageHelper');
const manualScreenshot = require('../helpers/manualScreenshot');
const richText = require('../helpers/oatmilkRichText');

function openGroup(page) {
  page.loadPath('setup_manual_oatmilk_group');
  page.waitFor('.group-page');
  page.waitFor('.topic-preview');
  page.execute("Array.from(document.querySelectorAll('.topic-preview')).find(el => el.textContent.includes('Returnable bottles for cafe customers')).classList.add('manual-topic')");
  page.waitFor('.manual-topic');
}

function openThreadMenu(page) {
  page.resizeWindow(1200, 1200);
  openGroup(page);
  page.click('.manual-topic .action-menu');
  page.waitFor('.v-overlay--active .v-list');
}

function openDiscussion(page) {
  page.loadPath('setup_manual_oatmilk_discussion');
  page.waitFor('.topic-page');
  page.waitFor('.new-comment');
}

function selectCommentForMove(page) {
  openDiscussion(page);
  page.click('.new-comment .action-menu');
  page.waitFor('.v-overlay--active .action-dock__button--move_event');
  page.click('.v-overlay--active .action-dock__button--move_event');
  page.waitFor('.discussion-fork-actions');
  page.waitFor('.topic-item__is-forking');
  page.click('.context-panel__heading');
}

function openMoveItemsModal(page) {
  selectCommentForMove(page);
  page.click('.discussion-fork-actions__move');
  page.waitFor('.modal-launcher .v-card');
  page.expectText('.modal-launcher .v-card', 'Move items');
}

module.exports = {
  '@tags': ['manual-screenshot'],

  'thread_management': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openThreadMenu(page);
    screenshot.captureRegion('discussions/discussion_management/thread_management', [
      '.manual-topic',
      '.v-overlay--active .v-list'
    ], {padding: 16, width: 1200, height: 1200});
  },

  'permissions_manage_threads': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openGroup(page);
    page.click('.group-page .action-menu--btn');
    page.waitFor('.v-overlay .action-dock__button--edit_group');
    page.click('.v-overlay .action-dock__button--edit_group');
    page.waitFor('.group-form');
    page.click('.group-form__permissions-tab');
    page.waitFor('.group-form__members-can-edit-discussions');
    page.execute("const input = document.querySelector('.group-form__members-can-edit-discussions input'); if (!input.checked) input.click()");
    screenshot.captureElement('discussions/discussion_management/permissions_manage_threads', '.group-form__members-can-edit-discussions', {
      width: 1100,
      height: 1000
    });
  },

  'pin_thread': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openThreadMenu(page);
    screenshot.captureRegion('discussions/discussion_management/pin_thread', [
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
  },

  'thread_edit': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openThreadMenu(page);
    page.clickElement('.v-overlay--active .action-dock__button--edit_discussion');
    page.waitFor('.discussion-form');
    screenshot.captureElement('discussions/discussion_management/thread_edit', '.discussion-form', {
      width: 1100,
      height: 1400
    });
  },

  'thread_move_group': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openThreadMenu(page);
    screenshot.captureRegion('discussions/discussion_management/thread_move_group', [
      '.manual-topic',
      '.v-overlay--active .v-list'
    ], {
      spotlight: {selector: '.v-overlay--active .action-dock__button--move_thread', padding: 8, radius: 12},
      padding: 16,
      width: 1200,
      height: 1200
    });
  },

  'move_thread_select': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openThreadMenu(page);
    page.clickElement('.v-overlay--active .action-dock__button--move_thread');
    page.waitFor('.move-topic-form');
    page.click('.move-topic-form__group-dropdown .v-field');
    page.waitFor('.v-overlay--active .v-list');
    screenshot.captureRegion('discussions/discussion_management/move_thread_select', [
      '.move-topic-form',
      '.v-overlay--active .v-list'
    ], {padding: 12, width: 1100, height: 1200});
  },

  'comment_move': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.click('.new-comment .action-menu');
    page.waitFor('.v-overlay--active .action-dock__button--move_event');
    screenshot.captureRegion('discussions/using_discussions/comment_move', [
      '.new-comment',
      '.v-overlay--active .v-list'
    ], {
      spotlight: {selector: '.v-overlay--active .action-dock__button--move_event', padding: 8, radius: 12},
      padding: 16,
      width: 1100,
      height: 1200
    });
  },

  'comment_select': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    selectCommentForMove(page);
    screenshot.capture('discussions/using_discussions/comment_select', {
      width: 1280,
      height: 1000
    });
  },

  'move_items': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    selectCommentForMove(page);
    screenshot.captureElement('discussions/using_discussions/move_items', '.topic-card', {
      width: 1100,
      height: 1600
    });
  },

  'move_items_new_thread': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openMoveItemsModal(page);
    page.click('.modal-launcher .v-card-actions .v-btn:first-of-type');
    page.waitFor('.discussion-form');
    page.fillIn('.discussion-form__title-input input', 'Cafe return tracking follow-up');
    page.fillRichText('.discussion-form .ProseMirror', richText.context('move-items-new-thread', [
      'Continue the detailed return tracking conversation in this focused discussion.',
      'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
      'Use the weekly totals to identify collection problems before the trial review.'
    ]));
    screenshot.captureElement('discussions/using_discussions/move_items_new_thread', '.discussion-form', {
      width: 1100,
      height: 1400
    });
  },

  'new_thread': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openMoveItemsModal(page);
    page.click('.modal-launcher .v-card-actions .v-btn:first-of-type');
    page.waitFor('.discussion-form');
    page.fillIn('.discussion-form__title-input input', 'Cafe return tracking follow-up');
    page.fillRichText('.discussion-form .ProseMirror', richText.context('move-items-confirm', [
      'Continue the detailed return tracking conversation in this focused discussion.',
      'Compare the number of bottles delivered, collected, damaged, and still held by each cafe.',
      'Use the weekly totals to identify collection problems before the trial review.'
    ]));
    page.click('.discussion-form__submit');
    page.waitForUrlToContain('/d/');
    page.waitFor('.context-panel__heading');
    page.expectText('.context-panel__heading', 'Cafe return tracking follow-up');
    page.click('.discussion-form .dismiss-modal-button');
    page.pause(500);
    page.expectText('.topic-page', 'I can ask three cafes to track');
    page.execute("document.querySelectorAll('.flash-root').forEach(el => el.remove())");
    screenshot.capture('discussions/using_discussions/new_thread', {
      width: 1280,
      height: 1000
    });
  },

  'copy_markdown_action': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.waitFor('.topic-sidebar .action-dock__button--copy_thread_for_ai');
    screenshot.capture('discussions/discussion_management/copy_markdown_action', {
      width: 1280,
      height: 1000,
      scrollSelector: '.topic-sidebar .action-dock__button--copy_thread_for_ai',
      spotlight: {
        selector: '.topic-sidebar .action-dock__button--copy_thread_for_ai',
        padding: 16,
        radius: 16,
        opacity: 0.4,
        outlineWidth: 0
      }
    });
  },

  'copy_markdown_dialog': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openDiscussion(page);
    page.click('.topic-sidebar .action-dock__button--copy_thread_for_ai');
    page.waitFor('.modal-launcher .v-card');
    page.expectText('.modal-launcher .v-card', 'Copy Markdown');
    page.waitFor('.modal-launcher .v-card-actions .v-btn:not([disabled])');
    screenshot.captureElement(
      'discussions/discussion_management/copy_markdown_dialog',
      '.modal-launcher .v-card',
      {width: 1100, height: 1200}
    );
  },

  'thread_delete': (test) => {
    const page = pageHelper(test);
    const screenshot = manualScreenshot(test);
    openThreadMenu(page);
    page.clickElement('.v-overlay--active .action-dock__button--discard_thread');
    page.waitFor('.confirm-modal');
    screenshot.captureElement('discussions/discussion_management/thread_delete', '.confirm-modal', {
      width: 1100,
      height: 1000
    });
  }
};
