require('coffeescript/register')
pageHelper = require('../helpers/pageHelper.coffee')

module.exports = {
  // 'presents_new_discussion_form_for_a_group_from_params': (test) => {
  //   page = pageHelper(test)
  //   page.loadPath('setup_start_thread_form_from_url')
  //   page.expectText('.discussion-form__group-select', "Dirty Dancing Shoes")
  //   page.expectValue('.discussion-form__title-input input', "testing title")
  // },
  // 'preselects_current_group': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_group')
  //   page.ensureSidebar()
  //
  //   page.click('.sidebar__list-item-button--start-thread')
  //   page.expectText('.discussion-form__group-select', 'Dirty Dancing Shoes')
  // },
  //
  'should_display_content_for_a_public_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.expectText('.group-page__name', 'Open Dirty Dancing Shoes')
    page.expectText('.thread-preview-collection__container', 'I carried a watermelon')
    page.expectText('.navbar__sign-in', 'LOG IN')
    page.click('.thread-preview__link')
    page.expectText('.context-panel__heading', 'I carried a watermelon')
  },

  'should_display_timestamps_on_content': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.click('.thread-preview__link')
    page.expectElement('.time-ago')
  },

  'can_close_and_reopen_a_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_and_closed_discussions')
    page.expectText('.thread-preview', 'What star sign are you?')
    page.click('.discussions-panel__filters')
    page.click('.discussions-panel__filters-closed')
    page.expectText('.thread-preview', 'This thread is old and closed')
    page.click('.discussions-panel__filters')
    page.click('.discussions-panel__filters-open')
    page.click('.thread-preview')
    page.click('.action-menu')
    page.click('.context-panel-dropdown__option--close_thread')
    page.expectFlash('Thread closed')

    page.pause(500)
    page.click('.flash-root__action')
    page.expectFlash('Thread reopened')
  },

  // 'doesnt store drafts after submission': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion')
  //   page.fillIn('.comment-form textarea', 'This is a comment')
  //   page.click('.comment-form__submit-button')
  //   page.expectNoText('.comment-form textarea', 'This is a comment')
  // },

  'lets_you_edit_title_and_context': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.action-menu')
    page.click('.action-dock__button--edit_thread')
    page.fillIn('.discussion-form__title-input input', 'better title')
    page.fillIn('.discussion-form .lmo-textarea textarea', 'improved description')
    page.click('.discussion-form__submit')
    page.click('.dismiss-modal-button', 500)
    page.expectText('.context-panel__heading', 'better title')
    page.expectText('.context-panel__description', 'improved description')
  },

  'does_not_store_cancelled_thread_info': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.action-menu')
    page.click('.action-dock__button--edit_thread')

    page.fillIn('.discussion-form__title-input input', 'dumb title')
    page.fillIn('.discussion-form .lmo-textarea textarea', 'rubbish description')
    page.click('.dismiss-modal-button', 500)

    page.click('.action-dock__button--edit_thread')

    page.expectNoText('.discussion-form__title-input input', 'dumb title')
    page.expectNoText('.discussion-form .lmo-textarea textarea', 'rubbish description')

  },

  // 'can_display_an_unread_content_line': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_unread_discussion')
  //   page.debug()
  //   page.expectElement('.thread-item--unread')
  // },

  'marks_a_discussion_as_seen': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_for_jennifer')
    page.ensureSidebar()
    page.expectText('.sidebar-item', 'Dirty Dancing Shoes (1)')
  },

  'lets_coordinators_and_thread_authors_delete_threads': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.action-menu')
    page.click('.context-panel-dropdown__option--delete_thread')
    page.click('.confirm-modal__submit')

    page.expectFlash('Thread deleted')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
    page.expectNoText('.discussions-panel', 'What star sign are you?')
  },

  'allows_logged_in_users_to_join_a_group_and_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')

    page.click('.thread-preview__link', 500)
    page.click('.join-group-button')
    page.expectFlash('You are now a member of Open Dirty Dancing Shoes')

    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'I am new!')
    page.click('.comment-form__submit-button', 500)
    page.expectFlash('Comment added')
  },

  'allows_guests_to_comment_and_view_thread_in_dashboard': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_as_guest')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'I am a guest!')
    page.click('.comment-form__submit-button')
    page.expectFlash('Comment added')

    page.ensureSidebar()

    page.click('.sidebar__list-item-button--recent')
    page.expectText('.thread-preview', 'Dirty Dancing Shoes')
  },

  'adds_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .ProseMirror', 'hi this is my comment')
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment', 'hi this is my comment')
  },

  'can_add_emojis': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Here is a heart!')
    page.click('.comment-form .emoji-picker__toggle')
    page.click('.emoji-picker__emojis span[title="heart"]')
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment .thread-item__body','Here is a heart!❤️')
  },

  'replies_to_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right heerrr')
    page.click('.comment-form__submit-button')
    page.click('.thread-item .action-menu')
    page.click('.context-panel-dropdown__option--reply_to_comment')

    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'hi this is my comment')
    page.click('.comment-form__submit-button')
    page.expectText('.event-children .new-comment__body', 'hi this is my comment')
    page.expectFlash('Patrick Swayze notified of reply')
  },

  'can_react_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.expectNoElement('.reaction')
    page.click('.emoji-picker__toggle')
    page.click('.emoji-picker__emojis span[title="heart"]')
    page.expectElement('.reactions-display')
  },

  'mentions_a_user': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@jennifer')
    page.expectText('.suggestion-list', 'Jennifer Grey')
    page.click('.suggestion-list .v-list-item__title')
    page.pause(1000)
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment', '@Jennifer Grey')
  },

  'edits_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.click('.action-dock__button--edit_comment')
    page.fillIn('.edit-comment-form .lmo-textarea div[contenteditable=true]', 'edited comment right thur')
    page.click('.edit-comment-form .comment-form__submit-button', 1000)
    page.expectText('.new-comment', 'edited comment right thur')
  },

  'lets_you_view_comment_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_comment_with_versions')
    page.click('.action-dock__button--show_history')
    page.expectText('.revision-history-content del', 'star')
    page.expectText('.revision-history-content ins', 'moon')
  },

  'lets_you_view_discussion_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_with_versions')
    page.click('.action-dock__button--show_history')
    page.expectText('.revision-history-content del', 'star')
    page.expectText('.revision-history-content ins', 'moon')
  },

  'deletes_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.click('.thread-item .action-menu')
    page.click('.context-panel-dropdown__option--delete_comment')
    page.click('.confirm-modal__submit')
    page.expectNoText('.activity-panel', 'original comment right thur')
  },

  'invites_a_user_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_new_discussion_email')
    page.click('.thread-mailer__subject a', 2000)
    page.expectText('.context-panel__heading', 'go to the moon')
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
    page.click('.comment-form__submit-button')
    page.expectText('.thread-item__title', 'Jennifer Grey', 10000)
    page.expectText('.thread-item__body', 'Hello world!')
    page.expectText('.context-panel__breadcrumbs', 'Girdy Dancing Shoes')
  },

  'invites_an_email_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_invitation_created_email')
    page.click('.thread-mailer__subject a', 2000)
    page.expectValue('.auth-email-form__email input', 'jen@example.com')
    page.signUpViaInvitation("Jennifer")
    page.expectFlash('Signed in successfully')
    page.expectText('.context-panel__heading', 'go to the moon', 10000)
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.expectText('.new-comment__body', 'body of the comment')
  },
}
