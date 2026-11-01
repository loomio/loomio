const pageHelper = require('../helpers/pageHelper');

module.exports = {
  'admins_can_save_the_attachment_checkbox_in_thread_settings': test => {
    const page = pageHelper(test);
    page.loadPath('setup_discussion');
    page.click('.topic-sidebar .action-dock__button--thread_settings');
    page.expectText('.topic-arrangement-form', 'Only admins can add attachments');
    test.assert.attributeContains('.topic-arrangement-form .v-card-item__append .help-link', 'href', '/en/user_manual/discussions/using_discussions#thread-settings');
    page.expectText('.topic-arrangement-form .v-card-item__append .help-link', 'Help');
    test.assert.not.selected('.topic-arrangement-form .topic-settings__single-poll input');
    page.click('.topic-settings__attachments-admin-only label');
    page.click('.topic-arrangement-form .v-card-actions button');
    page.expectFlash('Discussion updated');
    page.refreshAndWait();
    page.click('.topic-sidebar .action-dock__button--thread_settings');
    test.assert.selected('.topic-settings__attachments-admin-only input');
  },

  'members_can_post_text_without_attachment_controls_in_restricted_threads': test => {
    const page = pageHelper(test);
    page.loadPath('setup_attachment_restricted_discussion');
    page.expectElement('.comment-form .ProseMirror');
    page.expectNoElement('.comment-form .text-editor__attach');
    page.expectNoElement('.comment-form .text-editor__insert-image');
    page.fillIn('.comment-form .ProseMirror', 'My text contribution');
    page.click('.comment-form__submit-button');
    page.expectText('.new-comment', 'My text contribution');
  }
};
