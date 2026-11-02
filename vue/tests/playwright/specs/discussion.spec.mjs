import { test, expect } from '../fixtures.mjs';

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
test('should_display_content_for_a_public_thread', async ({ lmo: page }) => {
  await page.loadPath('view_open_group_as_visitor')
  await page.expectText('.group-page__name', 'Open Dirty Dancing Shoes')
  await page.expectText('.topic-preview-collection__container', 'I carried a watermelon')
  await page.expectText('.navbar__sign-in', 'Sign in')
  await page.click('.topic-preview__link')
  await page.expectText('.context-panel__heading', 'I carried a watermelon')
});

test('should_display_timestamps_on_content', async ({ lmo: page }) => {
  await page.loadPath('view_open_group_as_non_member')
  await page.expectElement('.topic-previews')
  await page.click('.topic-preview__link')
  await page.expectElement('.time-ago')
});

test('can_lock_and_unlock_a_thread', async ({ lmo: page }) => {
  await page.loadPath('setup_open_and_closed_discussions')
  await page.expectText('.topic-preview', 'What star sign are you?')
  await page.click('.discussions-panel__filters')
  await page.click('.discussions-panel__filters-locked')
  await page.expectText('.topic-preview', 'This thread is old and closed')
  await page.click('.discussions-panel__filters')
  await page.click('.discussions-panel__filters-all')
  await page.click('.topic-preview')
  await page.click('.topic-sidebar .action-dock__button--lock_thread')
  await page.expectFlash('Thread locked')
  // page.click('.flash-root__action')
  // page.expectFlash('Thread unlocked')
});

test('updates_thread_notification_status_after_saving', async ({ lmo: page }) => {
  await page.loadPath('setup_manual_oatmilk_discussion')
  await page.waitFor('.topic-sidebar__notification-email-icon')
  await page.expectNoElement('.topic-sidebar__notification-device-icon')
  await page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form--push-disabled')
  await page.click('.volume-loud label')
  await page.click('.change-volume-form__submit')
  await page.expectFlash('Notification settings updated')
  await page.expectElement('.topic-sidebar__notification-email-icon')
  await page.expectNoElement('.topic-sidebar__notification-device-icon')
  await page.expectText('.topic-sidebar__notification-settings', 'Email all activity')
  await page.expectNoElement('.change-volume-form', 8000)
  await page.clickAndWait('.topic-sidebar__notification-settings', '.change-volume-form--push-disabled')
  await page.click('.volume-quiet label')
  await page.click('.change-volume-form__submit')
  await page.expectFlash('Notification settings updated')
  await page.expectNoElement('.change-volume-form', 8000)
  await page.expectElement('.topic-sidebar__notification-email-icon')
  await page.expectNoElement('.topic-sidebar__notification-device-icon')
  await page.expectText('.topic-sidebar__notification-settings', 'Daily catch-up email')
});

test('lets_you_edit_title_and_context', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.context-panel .action-dock__button--edit_thread')
  await page.fillIn('.discussion-form__title-input input', 'better title')
  await page.fillIn('.discussion-form .lmo-textarea textarea', 'improved description')
  await page.click('.discussion-form__submit')
  await page.expectText('.context-panel__heading', 'better title')
  await page.expectText('.context-panel__description', 'improved description')
});

test('moves_a_group_thread_to_a_direct_thread', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.topic-sidebar .action-dock__button--move_thread')
  await page.click('.move-topic-form__group-dropdown .v-field')
  await page.expectText('.v-overlay-container', 'Direct thread')
  await page.click("//div[contains(@class, 'v-list-item-title') and normalize-space()='Direct thread']")
  await page.expectText('.move-topic-form', 'Everyone who has participated will retain access')
  await page.click('.move-topic-form__submit')
  await page.expectText('.context-panel__breadcrumbs', 'Direct')
});

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

test('lets_coordinators_and_thread_authors_delete_threads', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.topic-sidebar .action-dock__button--discard_thread')
  await page.click('.confirm-modal__submit')

  await page.expectFlash('Discussion deleted')
  await page.expectText('.group-page__name', 'Dirty Dancing Shoes')
  await page.expectNoText('.discussions-panel', 'What star sign are you?')
});

test('allows_logged_in_users_to_join_a_group_and_comment', async ({ lmo: page }) => {
  await page.loadPath('view_open_group_as_non_member')

  await page.click('.topic-preview__link', 500)
  await page.click('.join-group-button')
  await page.expectFlash('You are now a member of Open Dirty Dancing Shoes')

  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'I am new!')
  await page.click('.comment-form__submit-button', 500)
  await page.expectFlash('Comment added')
});

test('allows_guests_to_comment_and_view_thread_in_dashboard', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion_as_guest')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'I am a guest!')
  await page.click('.comment-form__submit-button')
  await page.expectFlash('Comment added')

  await page.ensureSidebar()

  await page.click('.sidebar__list-item-button--recent')
  await page.expectText('.topic-preview', 'Dirty Dancing Shoes')
});

test('adds_a_comment', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .ProseMirror', 'hi this is my comment')
  await page.click('.comment-form__submit-button')
  await page.expectText('.new-comment', 'hi this is my comment')
});

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

test('replies_to_a_comment', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right heerrr')
  await page.click('.comment-form__submit-button')
  await page.expectFlash('Comment added')
  await page.pause()
  await page.click('.new-comment .action-menu')

  await page.click('.action-dock__button--reply_to_comment')

  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'hi this is my comment')
  await page.click('.comment-form__submit-button')

  await page.expectText('.topic-list', 'hi this is my comment')
  // page.expectFlash('Patrick Swayze notified of reply')
});

test('can_react_to_a_discussion', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.expectNoElement('.reaction')
  await page.click('.emoji-picker__toggle')
  await page.click('.emoji-picker__emoji[data-shortcode="red_heart"]')
  await page.expectElement('.reactions-display')
});

test('mentions_a_user_in_wysiwyg', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.expectText('.mention-notifications-count', 'Type @ to notify people')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello @')
  await page.expectText('.suggestion-list', 'Dirty Dancing Shoes')
  await page.expectElement('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
  await page.click('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
  await page.expectText('.mention-notifications-count', '2 people will be notified')

  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@patrick')
  await page.expectText('.suggestion-list', 'Patrick Swayze')
  await page.expectElement('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
  await page.click('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
  await page.expectText('.mention-notifications-count', '1 person will be notified')

  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@jennifer')
  await page.expectText('.suggestion-list', 'Jennifer Grey')
  await page.expectElement('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.pause(200)
  await page.click('.comment-form__submit-button')
  await page.expectText('.new-comment', '@Jennifer Grey')
});

test('ranks_mention_prefix_matches_first', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion_for_mention_ranking')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@sco')
  await page.expectText('.suggestion-list .v-list-item:nth-child(1)', 'Scott Lemmon')
  await page.expectText('.suggestion-list .v-list-item:nth-child(2)', 'Jerry Scott')
});

test('preserves_a_published_mention_when_copying_and_pasting_it', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', '@jennifer')
  await page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.click('.comment-form__submit-button')
  await page.expectText('.new-comment', '@Jennifer Grey')

  await page.execute((mentionSelector) => {
    const mention = document.querySelector(mentionSelector)
    const selection = window.getSelection()
    const range = document.createRange()
    range.selectNodeContents(mention)
    selection.removeAllRanges()
    selection.addRange(range)
  }, '.new-comment span[data-mention-id="jennifergrey"]')
  await page.pause(100)
  await page.page.keyboard.press('ControlOrMeta+c')
  await page.execute((editorSelector) => {
    const editor = document.querySelector(editorSelector)
    const selection = window.getSelection()
    const destination = document.createRange()
    destination.selectNodeContents(editor.querySelector('p'))
    destination.collapse(false)
    selection.removeAllRanges()
    selection.addRange(destination)
    editor.focus()
  }, '.comment-form .lmo-textarea div[contenteditable=true]')
  await page.pause(100)
  await page.page.keyboard.press('ControlOrMeta+v')
  await page.expectText('.mention-notifications-count', '1 person will be notified')

  const value = await page.execute((editorSelector) => {
    const editor = document.querySelector(editorSelector)
    return {
      html: editor.innerHTML,
      text: editor.innerText,
      mentionCount: editor.querySelectorAll('span[data-mention-id="jennifergrey"]').length
    }
  }, '.comment-form .lmo-textarea div[contenteditable=true]')
  expect(value.mentionCount, JSON.stringify(value)).toBe(1)
});

test('mentions_a_user_in_markdown', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.click('.html-editor__expand')
  // page.click('i.mdi-chevron-right')
  await page.click('.e2e-markdown-btn')
  await page.acceptConfirm()
  await page.fillIn('.comment-form .lmo-textarea textarea', 'Hello @')
  await page.expectText('.suggestion-list', 'Dirty Dancing Shoes')
  await page.expectText('.suggestion-list', 'Jennifer Grey')
  await page.expectElement('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
  await page.click('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
  await page.expectText('.mention-notifications-count', '2 people will be notified')
  await page.fillIn('.comment-form .lmo-textarea textarea', '@jennifer')
  await page.expectText('.suggestion-list', 'Jennifer Grey')
  await page.expectElement('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.pause(200)
  await page.click('.comment-form__submit-button')
  await page.expectText('.new-comment', '@jennifergrey')
});

test('edits_a_comment', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
  await page.click('.comment-form__submit-button')
  await page.expectFlash('Comment added')
  await page.click('.action-dock__button--edit_comment')
  await page.fillIn('.edit-comment-form .lmo-textarea div[contenteditable=true]', 'edited comment right thur @patrick')
  await page.expectElement('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
  await page.click('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
  await page.click('.edit-comment-form .comment-form__submit-button', 1000)
  await page.expectText('.new-comment', 'edited comment right thur @Patrick Swayze')
});

test('lets_you_view_comment_revision_history', async ({ lmo: page }) => {
  await page.loadPath('setup_comment_with_versions')
  await page.expectText('.new-comment', 'What moon sign are you?')
  await page.click('.action-dock__button--show_history')
  await page.expectText('.revision-history-content del', 'star')
  await page.expectText('.revision-history-content ins', 'moon')
});

test('lets_you_view_discussion_revision_history', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion_with_versions')
  await page.click('.topic-new-discussion .action-dock__button--show_history')
  await page.expectText('.revision-history-content del', 'star')
  await page.expectText('.revision-history-content ins', 'moon')
});

test('escapes_markup_in_discussion_title_revision_history', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion_with_unsafe_title_version')
  await page.click('.topic-new-discussion .action-dock__button--show_history')
  await page.expectText('.revision-history-content ins', '<img src=x onerror=alert(document.domain)>')
  await page.expectNoElement('.revision-history-content img')
});

test('deletes_a_comment', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
  await page.click('.comment-form__submit-button')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--discard_comment')
  await page.expectNoText('.topic-card', 'original comment right thur')
  await page.expectText('.topic-card', 'Item removed')
});

test('discards_restores_deletes_a_comment', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
  await page.click('.comment-form__submit-button')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--discard_comment')
  await page.expectNoText('.topic-card', 'original comment right thur')
  await page.expectText('.topic-card', 'Item removed')
  await page.click('.topic-item__removed .action-menu')
  await page.click('.action-dock__button--undiscard_comment')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--discard_comment')
  await page.click('.topic-item__removed .action-menu')
  await page.click('.action-dock__button--delete_comment')
  await page.click('.confirm-modal__submit')
});

test('sign_in_from_discussion_announced_email', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_discussion_mailer_discussion_announced_email')
  await page.expectText('.email-notification-text', "invited you to a discussion")
  await page.expectText('.email-user-content', "A description for this discussion. Should this be rich?")
  await page.click('main h1 a', 2000)
  await page.expectText('.context-panel__heading', 'go to the moon')
  await page.expectText('.context-panel__description', 'A description for this discussion')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
  await page.click('.comment-form__submit-button')
  await page.expectText('.topic-item__title', 'Jennifer Grey', 10000)
  await page.expectText('.topic-item__body', 'Hello world!')
  await page.expectText('.context-panel__breadcrumbs', 'Girdy Dancing Shoes')
});

test('signed_out_member_signs_in_normally_from_discussion_invitation', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_discussion_mailer_member_invitation_signed_out')
  await page.expectText('.email-notification-text', 'invited you to a discussion')
  await page.click('main h1 a', 2000)
  await page.expectElement('.auth-modal')
  await page.fillIn('.auth-email-form__email input', 'discussion-member@example.com')
  await page.fillIn('.auth-email-form__password input', 'password')
  await page.click('.auth-email-form__submit')
  await page.expectFlash('Signed in successfully')
  await page.expectText('.context-panel__heading', 'Member invitation discussion', 10000)
});

test('sign_up_from_invitation_created_email', async ({ lmo: page }) => {
  await page.loadPathNoApp('setup_discussion_mailer_invitation_created_email')
  await page.expectText('.email-notification-text', "invited you to a discussion")
  await page.expectText('.email-user-content', "A description for this discussion. Should this be rich?")
  await page.expectText('body', 'Should we go to the moon?')
  await page.expectText('main', 'Poll details for the invitation email.')
  await page.expectText('main', 'Please vote')
  await page.expectText('main', 'Agree')
  await page.click('main h1 a', 2000)
  await page.expectValue('.auth-email-form__email input', 'jen@example.com')
  await page.signUpViaInvitation("Jennifer")
  await page.expectFlash('Signed in successfully')
  await page.expectText('.context-panel__heading', 'go to the moon', 10000)
  await page.expectText('.context-panel__description', 'A description for this discussion')
  await page.expectText('.new-comment__body', 'body of the comment')
});

test('can_move_comments_to_another_thread', async ({ lmo: page }) => {
  await page.loadPath('setup_forkable_discussion')
  await page.expectText('.topic-list', 'totally on topic')
  await page.expectText('.topic-list', 'totally off topic')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--move_event')
  await page.expectElement('.discussion-fork-actions')
  await page.click('.discussion-fork-actions__move')
  await page.pause(2000)
  await page.fillIn('.v-card .v-autocomplete input', 'Waking')
  await page.pause(2000)
  await page.click('.v-autocomplete__content .v-list-item__content')
  await page.pause(500)
  await page.click('.v-card-actions .v-btn:last-child')
  await page.pause(2000)
  // Should have navigated to the target thread
  await page.expectText('.context-panel__heading', 'Waking Up in Reno')
  await page.refresh()
  await page.pause(3000)
  // The moved comment should be in the target thread
  await page.expectText('.topic-list', 'totally on topic')
});

test('can_add_topical_poll_to_discussion', async ({ lmo: page }) => {
  await page.loadPath('setup_topical_poll_to_add_to_discussion')
  await page.expectText('.context-panel__heading', 'Topical proposal to move')
  await page.expectText('.topic-list', 'A comment on the topical poll')
  await page.execute("Array.from(document.querySelectorAll('.poll-created .action-menu--btn')).find(el => el.offsetParent).click()")
  await page.execute("Array.from(document.querySelectorAll('.action-dock__button--add_to_discussion')).find(el => el.offsetParent).click()")
  await page.expectText('.modal-launcher .v-card', 'Add to Discussion')
  await page.fillIn('.modal-launcher .v-autocomplete input', 'Waking')
  await page.pause(2000)
  await page.click('.v-autocomplete__content .v-list-item__content')
  await page.pause(500)
  await page.click('.modal-launcher .v-card-actions .v-btn:last-child')

  await page.expectText('.context-panel__heading', 'Waking Up in Reno', 15000)
  await page.expectText('.topic-list', 'Topical proposal to move')
  await page.expectText('.topic-list', 'A comment on the topical poll')
  await page.refresh()
  await page.expectText('.context-panel__heading', 'Waking Up in Reno')
  await page.expectText('.topic-list', 'Topical proposal to move')
  await page.expectText('.topic-list', 'A comment on the topical poll')
});

test('private_thread', async ({ lmo: page }) => {
  await page.loadPath('setup_discussion')
  await page.ensureSidebar()
  await page.click('.sidebar__list-item-button--private')
  await page.click('.topics-page__new-topic-button')
  await page.click('.discussion-templates--direct-discussion')
  await page.fillIn('.recipients-autocomplete input[type="text"]', 'test@example.com')
  await page.expectText('.recipients-autocomplete-suggestion', 'test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.fillIn('.discussion-form__title-input input', "private thread")
  await page.click('.discussion-form__submit')
  await page.expectFlash('Discussion started')
  await page.fillIn('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
  await page.click('.comment-form__submit-button')
  await page.expectFlash('Comment added')
});
