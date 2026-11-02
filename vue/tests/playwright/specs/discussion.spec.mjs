import { test, expect } from '../fixtures.mjs';
import { signUpViaInvitation } from '../helpers/accounts.mjs';

test('should_display_content_for_a_public_thread', async ({ page }) => {
  await page.goto('/dev/view_open_group_as_visitor')
  await expect(page.locator('.group-page__name')).toContainText('Open Dirty Dancing Shoes')
  await expect(page.locator('.topic-preview-collection__container')).toContainText('I carried a watermelon')
  await expect(page.locator('.navbar__sign-in')).toContainText('Sign in')
  await page.click('.topic-preview__link')
  await expect(page.locator('.context-panel__heading')).toContainText('I carried a watermelon')
});

test('should_display_timestamps_on_content', async ({ page }) => {
  await page.goto('/dev/view_open_group_as_non_member')
  await expect(page.locator('.topic-previews')).toBeVisible()
  await page.click('.topic-preview__link')
  await expect(page.locator('.time-ago')).toBeVisible()
});

test('can_lock_and_unlock_a_thread', async ({ page }) => {
  await page.goto('/dev/setup_open_and_closed_discussions')
  await expect(page.locator('.topic-preview')).toContainText('What star sign are you?')
  await page.click('.discussions-panel__filters')
  await page.click('.discussions-panel__filters-locked')
  await expect(page.locator('.topic-preview')).toContainText('This thread is old and closed')
  await page.click('.discussions-panel__filters')
  await page.click('.discussions-panel__filters-all')
  await page.click('.topic-preview')
  await page.click('.topic-sidebar .action-dock__button--lock_thread')
  await expect(page.locator('.flash-root__message')).toContainText('Thread locked')
});

test('updates_thread_notification_status_after_saving', async ({ page }) => {
  await page.goto('/dev/setup_manual_oatmilk_discussion')
  await expect(page.locator('.topic-sidebar__notification-email-icon')).toBeVisible()
  await expect(page.locator('.topic-sidebar__notification-device-icon')).toHaveCount(0)
  await page.click('.topic-sidebar__notification-settings')
  await page.click('.volume-loud label')
  await page.click('.change-volume-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Notification settings updated')
  await expect(page.locator('.topic-sidebar__notification-email-icon')).toBeVisible()
  await expect(page.locator('.topic-sidebar__notification-device-icon')).toHaveCount(0)
  await expect(page.locator('.topic-sidebar__notification-settings')).toContainText('Email all activity')
  await expect(page.locator('.change-volume-form')).toHaveCount(0)
  await page.click('.topic-sidebar__notification-settings')
  await page.click('.volume-quiet label')
  await page.click('.change-volume-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Notification settings updated')
  await expect(page.locator('.change-volume-form')).toHaveCount(0)
  await expect(page.locator('.topic-sidebar__notification-email-icon')).toBeVisible()
  await expect(page.locator('.topic-sidebar__notification-device-icon')).toHaveCount(0)
  await expect(page.locator('.topic-sidebar__notification-settings')).toContainText('Daily catch-up email')
});

test('lets_you_edit_title_and_context', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.context-panel .action-dock__button--edit_thread')
  await page.fill('.discussion-form__title-input input', 'better title')
  await page.fill('.discussion-form .lmo-textarea textarea', 'improved description')
  await page.click('.discussion-form__submit')
  await expect(page.locator('.context-panel__heading')).toContainText('better title')
  await expect(page.locator('.context-panel__description')).toContainText('improved description')
});

test('moves_a_group_thread_to_a_direct_thread', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.topic-sidebar .action-dock__button--move_thread')
  await page.click('.move-topic-form__group-dropdown .v-field')
  await expect(page.locator('.v-overlay-container')).toContainText('Direct thread')
  await page.click("//div[contains(@class, 'v-list-item-title') and normalize-space()='Direct thread']")
  await expect(page.locator('.move-topic-form')).toContainText('Everyone who has participated will retain access')
  await page.click('.move-topic-form__submit')
  await expect(page.locator('.context-panel__breadcrumbs')).toContainText('Direct')
});

test('lets_coordinators_and_thread_authors_delete_threads', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.topic-sidebar .action-dock__button--discard_thread')
  await page.click('.confirm-modal__submit')

  await expect(page.locator('.flash-root__message')).toContainText('Discussion deleted')
  await expect(page.locator('.group-page__name')).toContainText('Dirty Dancing Shoes')
  await expect(page.locator('.discussions-panel')).not.toContainText('What star sign are you?')
});

test('allows_logged_in_users_to_join_a_group_and_comment', async ({ page }) => {
  await page.goto('/dev/view_open_group_as_non_member')

  await page.click('.topic-preview__link')
  await page.click('.join-group-button')
  await expect(page.locator('.flash-root__message')).toContainText('You are now a member of Open Dirty Dancing Shoes')

  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'I am new!')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Comment added')
});

test('allows_guests_to_comment_and_view_thread_in_dashboard', async ({ page }) => {
  await page.goto('/dev/setup_discussion_as_guest')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'I am a guest!')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Comment added')

  await page.click('.navbar__sidenav-toggle')

  await page.click('.sidebar__list-item-button--recent')
  await expect(page.locator('.topic-preview')).toContainText('Dirty Dancing Shoes')
});

test('adds_a_comment', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.fill('.comment-form .ProseMirror', 'hi this is my comment')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.new-comment')).toContainText('hi this is my comment')
});

test('replies_to_a_comment', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right heerrr')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Comment added')
  await page.click('.new-comment .action-menu')

  await page.click('.action-dock__button--reply_to_comment')

  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'hi this is my comment')
  await page.click('.comment-form__submit-button')

  await expect(page.locator('.topic-list')).toContainText('hi this is my comment')
});

test('can_react_to_a_discussion', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await expect(page.locator('.reaction')).toHaveCount(0)
  await page.click('.emoji-picker__toggle')
  await page.click('.emoji-picker__emoji[data-shortcode="red_heart"]')
  await expect(page.locator('.reactions-display')).toBeVisible()
});

test('mentions_a_user_in_wysiwyg', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await expect(page.locator('.mention-notifications-count')).toContainText('Type @ to notify people')
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('Hello @')
  await expect(page.locator('.suggestion-list')).toContainText('Dirty Dancing Shoes')
  await page.click('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
  await expect(page.locator('.mention-notifications-count')).toContainText('2 people will be notified')

  await page.goto('/dev/setup_discussion')
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('@patrick')
  await expect(page.locator('.suggestion-list')).toContainText('Patrick Swayze')
  await page.click('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
  await expect(page.locator('.mention-notifications-count')).toContainText('1 person will be notified')

  await page.goto('/dev/setup_discussion')
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('@jennifer')
  await expect(page.locator('.suggestion-list')).toContainText('Jennifer Grey')
  await page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.new-comment')).toContainText('@Jennifer Grey')
});

test('ranks_mention_prefix_matches_first', async ({ page }) => {
  await page.goto('/dev/setup_discussion_for_mention_ranking')
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('@sco')
  await expect(page.locator('.suggestion-list .v-list-item:nth-child(1)')).toContainText('Scott Lemmon')
  await expect(page.locator('.suggestion-list .v-list-item:nth-child(2)')).toContainText('Jerry Scott')
});

test('preserves_a_published_mention_when_copying_and_pasting_it', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.locator('.comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('@jennifer')
  await page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.new-comment')).toContainText('@Jennifer Grey')

  await page.evaluate((mentionSelector) => {
    const mention = document.querySelector(mentionSelector)
    const selection = window.getSelection()
    const range = document.createRange()
    range.selectNodeContents(mention)
    selection.removeAllRanges()
    selection.addRange(range)
  }, '.new-comment span[data-mention-id="jennifergrey"]')
  await page.keyboard.press('ControlOrMeta+c')
  await page.evaluate((editorSelector) => {
    const editor = document.querySelector(editorSelector)
    const selection = window.getSelection()
    const destination = document.createRange()
    destination.selectNodeContents(editor.querySelector('p'))
    destination.collapse(false)
    selection.removeAllRanges()
    selection.addRange(destination)
    editor.focus()
  }, '.comment-form .lmo-textarea div[contenteditable=true]')
  await page.keyboard.press('ControlOrMeta+v')
  await expect(page.locator('.mention-notifications-count')).toContainText('1 person will be notified')

  const value = await page.evaluate((editorSelector) => {
    const editor = document.querySelector(editorSelector)
    return {
      html: editor.innerHTML,
      text: editor.innerText,
      mentionCount: editor.querySelectorAll('span[data-mention-id="jennifergrey"]').length
    }
  }, '.comment-form .lmo-textarea div[contenteditable=true]')
  expect(value.mentionCount, JSON.stringify(value)).toBe(1)
});

test('mentions_a_user_in_markdown', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.html-editor__expand')
  await page.click('.e2e-markdown-btn')
  await page.locator('.comment-form .lmo-textarea textarea').pressSequentially('Hello @')
  await expect(page.locator('.suggestion-list')).toContainText('Dirty Dancing Shoes')
  await expect(page.locator('.suggestion-list')).toContainText('Jennifer Grey')
  await page.click('.suggestion-list [data-mention-handle="shoes"] .v-list-item-title')
  await expect(page.locator('.mention-notifications-count')).toContainText('2 people will be notified')
  await page.locator('.comment-form .lmo-textarea textarea').pressSequentially('@jennifer')
  await expect(page.locator('.suggestion-list')).toContainText('Jennifer Grey')
  await page.click('.suggestion-list [data-mention-handle="jennifergrey"] .v-list-item-title')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.new-comment')).toContainText('@jennifergrey')
});

test('edits_a_comment', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Comment added')
  await page.click('.action-dock__button--edit_comment')
  await page.locator('.edit-comment-form .lmo-textarea div[contenteditable=true]').pressSequentially('edited comment right thur @patrick')
  await page.click('.suggestion-list [data-mention-handle="patrickswayze"] .v-list-item-title')
  await page.click('.edit-comment-form .comment-form__submit-button')
  await expect(page.locator('.new-comment')).toContainText('edited comment right thur @Patrick Swayze')
});

test('lets_you_view_comment_revision_history', async ({ page }) => {
  await page.goto('/dev/setup_comment_with_versions')
  await expect(page.locator('.new-comment')).toContainText('What moon sign are you?')
  await page.click('.action-dock__button--show_history')
  await expect(page.locator('.revision-history-content del')).toContainText('star')
  await expect(page.locator('.revision-history-content ins')).toContainText('moon')
});

test('lets_you_view_discussion_revision_history', async ({ page }) => {
  await page.goto('/dev/setup_discussion_with_versions')
  await page.click('.topic-new-discussion .action-dock__button--show_history')
  await expect(page.locator('.revision-history-content del')).toContainText('star')
  await expect(page.locator('.revision-history-content ins')).toContainText('moon')
});

test('escapes_markup_in_discussion_title_revision_history', async ({ page }) => {
  await page.goto('/dev/setup_discussion_with_unsafe_title_version')
  await page.click('.topic-new-discussion .action-dock__button--show_history')
  await expect(page.locator('.revision-history-content ins')).toContainText('<img src=x onerror=alert(document.domain)>')
  await expect(page.locator('.revision-history-content img')).toHaveCount(0)
});

test('deletes_a_comment', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
  await page.click('.comment-form__submit-button')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--discard_comment')
  await expect(page.locator('.topic-card')).not.toContainText('original comment right thur')
  await expect(page.locator('.topic-card')).toContainText('Item removed')
});

test('discards_restores_deletes_a_comment', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'original comment right hur')
  await page.click('.comment-form__submit-button')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--discard_comment')
  await expect(page.locator('.topic-card')).not.toContainText('original comment right thur')
  await expect(page.locator('.topic-card')).toContainText('Item removed')
  await page.click('.topic-item__removed .action-menu')
  await page.click('.action-dock__button--undiscard_comment')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--discard_comment')
  await page.click('.topic-item__removed .action-menu')
  await page.click('.action-dock__button--delete_comment')
  await page.click('.confirm-modal__submit')
});

test('sign_in_from_discussion_announced_email', async ({ page }) => {
  await page.goto('/dev/setup_discussion_mailer_discussion_announced_email')
  await expect(page.locator('.email-notification-text')).toContainText("invited you to a discussion")
  await expect(page.locator('.email-user-content')).toContainText("A description for this discussion. Should this be rich?")
  await page.click('main h1 a')
  await expect(page.locator('.context-panel__heading')).toContainText('go to the moon')
  await expect(page.locator('.context-panel__description')).toContainText('A description for this discussion')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.topic-item__title')).toContainText('Jennifer Grey', { timeout: 10000 })
  await expect(page.locator('.topic-item__body')).toContainText('Hello world!')
  await expect(page.locator('.context-panel__breadcrumbs')).toContainText('Girdy Dancing Shoes')
});

test('signed_out_member_signs_in_normally_from_discussion_invitation', async ({ page }) => {
  await page.goto('/dev/setup_discussion_mailer_member_invitation_signed_out')
  await expect(page.locator('.email-notification-text')).toContainText('invited you to a discussion')
  await page.click('main h1 a')
  await expect(page.locator('.auth-modal')).toBeVisible()
  await page.locator('.auth-email-form__email input').pressSequentially('discussion-member@example.com')
  await page.fill('.auth-email-form__password input', 'password')
  await page.click('.auth-email-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.context-panel__heading')).toContainText('Member invitation discussion', { timeout: 10000 })
});

test('sign_up_from_invitation_created_email', async ({ page }) => {
  await page.goto('/dev/setup_discussion_mailer_invitation_created_email')
  await expect(page.locator('.email-notification-text')).toContainText("invited you to a discussion")
  await expect(page.locator('.email-user-content')).toContainText("A description for this discussion. Should this be rich?")
  await expect(page.locator('body')).toContainText('Should we go to the moon?')
  await expect(page.locator('main')).toContainText('Poll details for the invitation email.')
  await expect(page.locator('main')).toContainText('Please vote')
  await expect(page.locator('main')).toContainText('Agree')
  await page.click('main h1 a')
  await expect(page.locator('.auth-email-form__email input')).toHaveValue('jen@example.com')
  await signUpViaInvitation(page, "Jennifer")
  await expect(page.locator('.flash-root__message')).toContainText('Signed in successfully')
  await expect(page.locator('.context-panel__heading')).toContainText('go to the moon', { timeout: 10000 })
  await expect(page.locator('.context-panel__description')).toContainText('A description for this discussion')
  await expect(page.locator('.new-comment__body')).toContainText('body of the comment')
});

test('can_move_comments_to_another_thread', async ({ page }) => {
  await page.goto('/dev/setup_forkable_discussion')
  await expect(page.locator('.topic-list')).toContainText('totally on topic')
  await expect(page.locator('.topic-list')).toContainText('totally off topic')
  await page.click('.new-comment .action-menu')
  await page.click('.action-dock__button--move_event')
  await expect(page.locator('.discussion-fork-actions')).toBeVisible()
  await page.click('.discussion-fork-actions__move')
  await page.fill('.v-card .v-autocomplete input', 'Waking')
  await page.click('.v-autocomplete__content .v-list-item__content')
  await page.click('.v-card-actions .v-btn:last-child')
  // Should have navigated to the target thread
  await expect(page.locator('.context-panel__heading')).toContainText('Waking Up in Reno')
  await page.reload()
  // The moved comment should be in the target thread
  await expect(page.locator('.topic-list')).toContainText('totally on topic')
});

test('can_add_topical_poll_to_discussion', async ({ page }) => {
  await page.goto('/dev/setup_topical_poll_to_add_to_discussion')
  await expect(page.locator('.context-panel__heading')).toContainText('Topical proposal to move')
  await expect(page.locator('.topic-list')).toContainText('A comment on the topical poll')
  await page.click('.poll-created .action-menu--btn:visible')
  await page.click('.action-dock__button--add_to_discussion:visible')
  await expect(page.locator('.modal-launcher .v-card')).toContainText('Add to Discussion')
  await page.fill('.modal-launcher .v-autocomplete input', 'Waking')
  await page.click('.v-autocomplete__content .v-list-item__content')
  await page.click('.modal-launcher .v-card-actions .v-btn:last-child')

  await expect(page.locator('.context-panel__heading')).toContainText('Waking Up in Reno', { timeout: 15000 })
  await expect(page.locator('.topic-list')).toContainText('Topical proposal to move')
  await expect(page.locator('.topic-list')).toContainText('A comment on the topical poll')
  await page.reload()
  await expect(page.locator('.context-panel__heading')).toContainText('Waking Up in Reno')
  await expect(page.locator('.topic-list')).toContainText('Topical proposal to move')
  await expect(page.locator('.topic-list')).toContainText('A comment on the topical poll')
});

test('private_thread', async ({ page }) => {
  await page.goto('/dev/setup_discussion')
  await page.click('.navbar__sidenav-toggle')
  await page.click('.sidebar__list-item-button--private')
  await page.click('.topics-page__new-topic-button')
  await page.click('.discussion-templates--direct-discussion')
  await page.locator('.recipients-autocomplete input[type="text"]').pressSequentially('test@example.com')
  await expect(page.locator('.recipients-autocomplete-suggestion')).toContainText('test@example.com')
  await page.click('.recipients-autocomplete-suggestion')
  await page.fill('.discussion-form__title-input input', "private thread")
  await page.click('.discussion-form__submit')
  await expect(page.locator('.flash-root__message')).toContainText('Discussion started')
  await page.fill('.comment-form .lmo-textarea div[contenteditable=true]', 'Hello world!')
  await page.click('.comment-form__submit-button')
  await expect(page.locator('.flash-root__message')).toContainText('Comment added')
});
