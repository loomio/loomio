pageHelper = require('../helpers/pageHelper')

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
  //   page.click('.sidebar-start-thread')
  //   page.expectText('.discussion-form__group-select', 'Dirty Dancing Shoes')
  // },
  //
  'should_display_content_for_a_public_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.expectText('.group-page__name', 'Open Dirty Dancing Shoes')
    page.expectText('.topic-preview-collection__container', 'I carried a watermelon')
    page.expectText('.navbar__sign-in', 'Sign in')
    page.click('.topic-preview__link')
    page.expectText('.context-panel__heading', 'I carried a watermelon')
  },

  'should_display_timestamps_on_content': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.expectElement('.topic-previews')
    page.click('.topic-preview__link')
    page.expectElement('.time-ago')
  },

  'can_lock_and_unlock_a_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_and_closed_discussions')
    page.expectText('.topic-preview', 'What star sign are you?')
    page.click('.discussions-panel__filters')
    page.click('.discussions-panel__filters-locked')
    page.expectText('.topic-preview', 'This thread is old and closed')
    page.click('.discussions-panel__filters')
    page.click('.discussions-panel__filters-all')
    page.click('.topic-preview')
    page.click('.topic-sidebar .action-dock__button--lock_thread')
    page.expectFlash('Thread locked')
    // page.click('.flash-root__action')
    // page.expectFlash('Thread unlocked')
  },

  'updates_thread_notification_status_after_saving': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_manual_oatmilk_discussion')
    page.waitFor('.topic-sidebar__notification-email-icon')
    page.expectNoElement('.topic-sidebar__notification-device-icon')
    page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form--push-disabled')
    page.click('.volume-loud label')
    page.click('.change-volume-form__submit')
    page.expectFlash('Notification settings updated')
    page.expectElement('.topic-sidebar__notification-email-icon')
    page.expectNoElement('.topic-sidebar__notification-device-icon')
    page.expectText('.topic-sidebar__notification-settings', 'All activity')
    page.expectNoElement('.change-volume-form', 8000)
    page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form--push-disabled')
    page.click('.volume-quiet label')
    page.click('.change-volume-form__submit')
    page.expectFlash('Notification settings updated')
    page.expectElement('.topic-sidebar__notification-email-icon')
    page.expectNoElement('.topic-sidebar__notification-device-icon')
    page.expectText('.topic-sidebar__notification-settings', 'Daily catch-up email')
  },

  'lets_you_edit_title_and_context': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel .action-dock__button--edit_thread')
    page.fillIn('.discussion-form__title-input input', 'better title')
    page.fillIn('.discussion-form .lmo-textarea textarea', 'improved description')
    page.click('.discussion-form__submit')
    page.expectText('.context-panel__heading', 'better title')
    page.expectText('.context-panel__description', 'improved description')
  },

  'moves_a_group_thread_to_a_direct_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.topic-sidebar .action-dock__button--move_thread')
    page.click('.move-topic-form__group-dropdown .v-field')
    page.expectText('.v-overlay-container', 'Direct thread')
    test.useXpath().click("//div[contains(@class, 'v-list-item-title') and normalize-space()='Direct thread']").useCss()
    page.expectText('.move-topic-form', 'Everyone who has participated will retain access')
    page.click('.move-topic-form__submit')
    page.expectText('.context-panel__breadcrumbs', 'Direct')
  },

  // 'stores_draft_edits': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion')
  //   page.click('.action-menu')
  //   page.click('.action-dock__button--edit_thread')
  //
  //   page.fillIn('.discussion-form__title-input input', 'dumb title')
  //   page.fillIn('.discussion-form .lmo-textarea textarea', 'rubbish description')
  //
  //   page.refresh()
  //
  //   page.expectText('.discussion-form__title-input input', 'dumb title')
  //   page.expectText('.discussion-form .lmo-textarea textarea', 'rubbish description')
  //
  // },

  // 'can_display_an_unread_content_line': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_unread_discussion')
  //   page.debug()
  //   page.expectElement('.topic-item--unread')
  // },

  // 'marks_a_discussion_as_seen': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion_for_jennifer')
  //   page.ensureSidebar()
  //   page.expectText('.sidebar__groups', 'Dirty Dancing Shoes (1)')
  // },

  'lets_coordinators_and_thread_authors_delete_threads': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.topic-sidebar .action-dock__button--discard_thread')
    page.click('.confirm-modal__submit')

    page.expectFlash('Discussion deleted')
    page.expectText('.group-page__name', 'Dirty Dancing Shoes')
    page.expectNoText('.discussions-panel', 'What star sign are you?')
  },

  'allows_logged_in_users_to_join_a_group_and_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')

    page.click('.topic-preview__link', 500)
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
    page.expectText('.topic-preview', 'Dirty Dancing Shoes')
  },

  'adds_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .ProseMirror', 'hi this is my comment')
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment', 'hi this is my comment')
  },

  // 'can_add_emojis': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion')
  //   page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Here is a heart!')
  //   page.click('.comment-form .emoji-picker__toggle')
  //   page.click('.emoji-picker__emojis img[alt="heart"]')
  //   page.click('.comment-form__submit-button')
  //   page.expectText('.new-comment .topic-item__body','Here is a heart!❤️')
  // },

  'replies_to_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right heerrr')
    page.click('.comment-form__submit-button')
    page.expectFlash('Comment added')
    page.pause()
    page.click('.new-comment .action-menu')

    page.click('.action-dock__button--reply_to_comment')

    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'hi this is my comment')
    page.click('.comment-form__submit-button')

    page.expectText('.topic-list', 'hi this is my comment')
    // page.expectFlash('Patrick Swayze notified of reply')
  },

  'can_react_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.expectNoElement('.reaction')
    page.click('.emoji-picker__toggle')
    page.click('.emoji-picker__emoji[data-shortcode="red_heart"]')
    page.expectElement('.reactions-display')
  },

  'mentions_a_user_in_wysiwyg': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.expectText('.mention-notifications-count', 'Type @ to notify people')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello @')
    page.expectText('.suggestion-list', 'Dirty Dancing Shoes')
    page.expectElement('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
    page.click('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
    page.expectText('.mention-notifications-count', '2 people will be notified')

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@patrick')
    page.expectText('.suggestion-list', 'Patrick Swayze')
    page.expectElement('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
    page.click('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
    page.expectText('.mention-notifications-count', '1 person will be notified')

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@jennifer')
    page.expectText('.suggestion-list', 'Jennifer Grey')
    page.expectElement('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
    page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
    page.pause(200)
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment', '@Jennifer Grey')
  },

  'ranks_mention_prefix_matches_first': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_for_mention_ranking')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@sco')
    page.expectText('.suggestion-list .v-list-item:nth-child(1)', 'Scott Lemmon')
    page.expectText('.suggestion-list .v-list-item:nth-child(2)', 'Jerry Scott')
  },

  'mentions_a_user_in_markdown': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.html-editor__expand')
    // page.click('i.mdi-chevron-right')
    page.click('.e2e-markdown-btn')
    page.acceptConfirm()
    page.fillIn('.comment-form .lmo-textarea textarea', 'Hello @')
    page.expectText('.suggestion-list', 'Dirty Dancing Shoes')
    page.expectText('.suggestion-list', 'Jennifer Grey')
    page.expectElement('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
    page.click('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
    page.expectText('.mention-notifications-count', '2 people will be notified')
    page.fillIn('.comment-form .lmo-textarea textarea', '@jennifer')
    page.expectText('.suggestion-list', 'Jennifer Grey')
    page.expectElement('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
    page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
    page.pause(200)
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment', '@jennifergrey')
  },

  'edits_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.expectFlash('Comment added')
    page.click('.action-dock__button--edit_comment')
    page.fillIn('.edit-comment-form .lmo-textarea div[contenteditable=true]', 'edited comment right thur')
    page.click('.edit-comment-form .comment-form__submit-button', 1000)
    page.expectText('.new-comment', 'edited comment right thur')
  },

  'lets_you_view_comment_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_comment_with_versions')
    page.expectText('.new-comment', 'What moon sign are you?')
    page.click('.action-dock__button--show_history')
    page.expectText('.revision-history-content del', 'star')
    page.expectText('.revision-history-content ins', 'moon')
  },

  'lets_you_view_discussion_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_with_versions')
    page.click('.topic-new-discussion .action-dock__button--show_history')
    page.expectText('.revision-history-content del', 'star')
    page.expectText('.revision-history-content ins', 'moon')
  },

  'escapes_markup_in_discussion_title_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_with_unsafe_title_version')
    page.click('.topic-new-discussion .action-dock__button--show_history')
    page.expectText('.revision-history-content ins', '<img src=x onerror=alert(document.domain)>')
    page.expectNoElement('.revision-history-content img')
  },

  'deletes_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.click('.new-comment .action-menu')
    page.click('.action-dock__button--discard_comment')
    page.expectNoText('.topic-card', 'original comment right thur')
    page.expectText('.topic-card', 'Item removed')
  },

  'discards_restores_deletes_a_comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.click('.new-comment .action-menu')
    page.click('.action-dock__button--discard_comment')
    page.expectNoText('.topic-card', 'original comment right thur')
    page.expectText('.topic-card', 'Item removed')
    page.click('.topic-item__removed .action-menu')
    page.click('.action-dock__button--undiscard_comment')
    page.click('.new-comment .action-menu')
    page.click('.action-dock__button--discard_comment')
    page.click('.topic-item__removed .action-menu')
    page.click('.action-dock__button--delete_comment')
    page.click('.confirm-modal__submit')
  },

  'sign_in_from_discussion_announced_email': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_discussion_announced_email')
    page.expectText('.email-notification-text', "invited you to a discussion")
    page.expectText('.email-user-content', "A description for this discussion. Should this be rich?")
    page.click('main h1 a', 2000)
    page.expectText('.context-panel__heading', 'go to the moon')
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
    page.click('.comment-form__submit-button')
    page.expectText('.topic-item__title', 'Jennifer Grey', 10000)
    page.expectText('.topic-item__body', 'Hello world!')
    page.expectText('.context-panel__breadcrumbs', 'Girdy Dancing Shoes')
  },

  'sign_up_from_invitation_created_email': (test) => {
    page = pageHelper(test)

    page.loadPathNoApp('setup_discussion_mailer_invitation_created_email')
    page.expectText('.email-notification-text', "invited you to a discussion")
    page.expectText('.email-user-content', "A description for this discussion. Should this be rich?")
    page.expectText('body', 'Should we go to the moon?')
    page.expectText('main', 'Poll details for the invitation email.')
    page.expectText('main', 'Please vote')
    page.expectText('main', 'Agree')
    page.click('main h1 a', 2000)
    page.expectValue('.auth-email-form__email input', 'jen@example.com')
    page.signUpViaInvitation("Jennifer")
    page.expectFlash('Signed in successfully')
    page.expectText('.context-panel__heading', 'go to the moon', 10000)
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.expectText('.new-comment__body', 'body of the comment')
  },

  'can_move_comments_to_another_thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_forkable_discussion')
    page.expectText('.topic-list', 'totally on topic')
    page.expectText('.topic-list', 'totally off topic')
    page.click('.new-comment .action-menu')
    page.click('.action-dock__button--move_event')
    page.expectElement('.discussion-fork-actions')
    page.click('.discussion-fork-actions__move')
    page.pause(2000)
    page.fillIn('.v-card .v-autocomplete input', 'Waking')
    page.pause(2000)
    page.click('.v-autocomplete__content .v-list-item__content')
    page.pause(500)
    page.click('.v-card-actions .v-btn:last-child')
    page.pause(2000)
    // Should have navigated to the target thread
    page.expectText('.context-panel__heading', 'Waking Up in Reno')
    page.refresh()
    page.pause(3000)
    // The moved comment should be in the target thread
    page.expectText('.topic-list', 'totally on topic')
  },

  'can_add_topical_poll_to_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_topical_poll_to_add_to_discussion')
    page.expectText('.context-panel__heading', 'Topical proposal to move')
    page.expectText('.topic-list', 'A comment on the topical poll')
    page.execute("Array.from(document.querySelectorAll('.poll-created .action-menu--btn')).find(el => el.offsetParent).click()")
    page.execute("Array.from(document.querySelectorAll('.action-dock__button--add_to_discussion')).find(el => el.offsetParent).click()")
    page.expectText('.modal-launcher .v-card', 'Add to Discussion')
    page.fillIn('.modal-launcher .v-autocomplete input', 'Waking')
    page.pause(2000)
    page.click('.v-autocomplete__content .v-list-item__content')
    page.pause(500)
    page.click('.modal-launcher .v-card-actions .v-btn:last-child')
    page.pause(3000)

    page.expectText('.context-panel__heading', 'Waking Up in Reno')
    page.expectText('.topic-list', 'Topical proposal to move')
    page.expectText('.topic-list', 'A comment on the topical poll')
    page.refresh()
    page.expectText('.context-panel__heading', 'Waking Up in Reno')
    page.expectText('.topic-list', 'Topical proposal to move')
    page.expectText('.topic-list', 'A comment on the topical poll')
  },

  'private_thread': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_discussion')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--private')
    page.click('.topics-page__new-topic-button')
    page.click('.discussion-templates--direct-discussion')
    page.fillIn('.recipients-autocomplete input', 'test@example.com')
    page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
    page.click('.recipients-autocomplete-suggestion')
    page.fillIn('.discussion-form__title-input input', "private thread")
    page.click('.discussion-form__submit')
    page.expectFlash('Discussion started')
    page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
    page.click('.comment-form__submit-button')
    page.expectFlash('Comment added')
  }
}
