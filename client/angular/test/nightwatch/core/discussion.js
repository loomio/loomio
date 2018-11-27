require('coffeescript/register')
pageHelper = require('../helpers/page_helper')
workflowHelper = require('../helpers/workflow_helper')

module.exports = {
  'presents_new_discussion_form_for_a_group_from_params': (test) => {
    page = pageHelper(test)
    page.loadPath('setup_start_thread_form_from_url')
    page.expectText('discussion_form', "Dirty Dancing Shoes")
    page.expectValue('.discussion-form__title-input', "testing title")
  },
  'preselects current group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_group')
    page.ensureSidebar()
    page.click('.sidebar__list-item-button--start-thread')
    page.expectText('.discussion-form__group-select', 'Dirty Dancing Shoes')
  },

  'should display content for a public thread': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_visitor')
    page.expectText('.group-theme__name', 'Open Dirty Dancing Shoes')
    page.expectText('.thread-previews-container--unpinned', 'I carried a watermelon')
    page.expectText('.navbar__right', 'LOG IN')
    page.click('.thread-preview__link')
    page.expectText('.context-panel__heading', 'I carried a watermelon')
  },

  'should display timestamps on content': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.click('.thread-preview__link')
    page.expectElement('.timeago')
  },

  'can close and reopen a thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_open_and_closed_discussions')
    page.expectText('.discussions-card__header', 'Open threads')
    page.expectText('.discussions-card__header', '1 Closed')
    page.expectNoText('.thread-preview__title', 'This thread is old and closed')
    page.expectText('.thread-preview__title', 'What star sign are you?')

    page.click('.thread-preview')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--close')
    page.expectText('.flash-root__message', 'Thread closed')
    page.click('.flash-root__action')
    page.expectText('.flash-root__message', 'Thread reopened')
  },

  'doesnt store drafts after submission': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form textarea', 'This is a comment')
    page.click('.comment-form__submit-button')
    page.expectNoText('.comment-form textarea', 'This is a comment')
  },

  'lets you edit title, context and privacy': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--edit')
    page.fillIn('.discussion-form__title-input', 'better title')
    page.fillIn('.discussion-form textarea', 'improved description')
    page.click('.discussion-form__private')
    page.click('.discussion-form__submit')
    page.click('.dismiss-modal-button')
    page.pause()
    page.expectText('.context-panel__heading', 'better title')
    page.expectText('.context-panel__description', 'improved description')
    page.expectText('.context-panel', 'Private')
  },

  'does_not_store_cancelled_thread_info': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--edit')

    page.fillIn('.discussion-form__title-input', 'dumb title')
    page.fillIn('.discussion-form textarea', 'rubbish description')

    page.click('.discussion-modal .modal-cancel')

    page.pause()

    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--edit')

    page.expectNoText('.discussion-form__title-input', 'dumb title')
    page.expectNoText('.discussion-form textarea', 'rubbish description')
  },

  'can display an unread content line': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_unread_discussion')
    page.expectElement('.thread-item--unread')
  },

  'lets you mute and unmute': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_multiple_discussions')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--mute')
    page.click('.confirm-modal__submit')
    page.expectText('.flash-root__message', 'Thread muted')
    page.pause()

    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--unmute')
    page.expectText('.flash-root__message', 'Thread unmuted')
  },

  'lets you move a thread': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_multiple_discussions')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--move')
    page.click('.move-thread-form__group-dropdown')
    page.click('.md-select-menu-container.md-active md-option')
    page.click('.move-thread-form__submit')
    page.expectText('.flash-root__message', 'Thread has been moved to Point Break')
    page.expectText('.thread-item__title', 'Patrick Swayze moved the thread from Dirty Dancing Shoes')
    page.expectText('.group-theme__name--compact','Point Break')
  },

  'marks a discussion as seen': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_for_jennifer')
    page.ensureSidebar()
    page.expectText('.md-sidenav-left', 'Unread threads')
  },

  'lets coordinators and thread authors delete threads': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--delete button')
    page.click('.confirm-modal__submit')

    page.expectText('.flash-root__message', 'Thread deleted')
    page.expectText('.group-theme__name', 'Dirty Dancing Shoes')
    page.expectNoText('.discussions-card', 'What star sign are you?')
  },

  'can pin from the discussion page': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--pin button')

    page.expectText('.confirm-modal', 'Pinned threads always appear')
    page.click('.confirm-modal__submit')

    page.expectText('.flash-root__message', 'Thread pinned')
    page.expectElement('.context-panel__status .mdi-pin')
  },

  'lets you change thread volume': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--email-settings')
    page.click('#volume-loud')
    page.click('.change-volume-form__submit')
    page.expectText('.flash-root__message', 'You will be emailed activity in this thread.')
  },

  'lets you change the volume for all threads in the group': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.click('.context-panel-dropdown__button')
    page.click('.context-panel-dropdown__option--email-settings')
    page.click('#volume-loud')
    page.click('.change-volume-form__apply-to-all')
    page.click('.change-volume-form__submit')
    page.expectText('.flash-root__message', 'You will be emailed all activity in this group.')
  },

  'allows logged in users to join a group and comment': (test) => {
    page = pageHelper(test)

    page.loadPath('view_open_group_as_non_member')
    page.click('.thread-preview__link')
    page.click('.join-group-button__join-group')
    page.expectText('.flash-root__message', 'You are now a member of Open Dirty Dancing Shoes')

    page.fillIn('.comment-form textarea', 'I am new!')
    page.click('.comment-form__submit-button')
    page.pause(2000)
    page.expectText('.flash-root__message', 'Comment added')
  },

  'allows guests to comment and view thread in dashboard': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_as_guest')
    page.fillIn('.comment-form textarea', 'I am a guest!')
    page.click('.comment-form__submit-button')
    page.expectText('.flash-root__message', 'Comment added')

    page.ensureSidebar()
    page.click('.sidebar__list-item-button--recent')
    page.expectText('.thread-preview__text-container', 'Dirty Dancing Shoes')
  },

  'allows logged in users to request to join a closed group': (test) => {
    page = pageHelper(test)

    page.loadPath('view_closed_group_as_non_member')
    page.click('.thread-preview__link')
    page.click('.join-group-button__ask-to-join-group')
    page.click('.membership-request-form__submit-btn')
    page.expectText('.flash-root__message', 'You have requested membership to Closed Dirty Dancing Shoes')
  },

  'adds a comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form textarea', 'hi this is my comment')
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment', 'hi this is my comment', 8000)
  },

  'can add emojis': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form textarea', 'Here is a dragon!')
    page.click('.comment-form .emoji-picker__toggle')
    page.fillIn('.md-open-menu-container.md-active .emoji-picker__search input', 'dragon_face')
    page.pause(250)
    page.click('.md-open-menu-container.md-active .emoji-picker__link')
    page.pause(250)
    page.click('.comment-form__submit-button')
    page.expectText('.new-comment .thread-item__body','Here is a dragon!')
    page.expectElement('.new-comment .thread-item__body img')
  },

  'replies to a comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form textarea', 'original comment right heerrr')
    page.click('.comment-form__submit-button')
    page.click('.action-dock__button--reply_to_comment')
    page.fillIn('.comment-form textarea', 'hi this is my comment')
    page.click('.comment-form__submit-button')
    page.expectText('.thread-item--indent .new-comment__body', 'hi this is my comment')
    page.expectText('.flash-root__message', 'Patrick Swayze notified of reply')
  },

  'can react to a comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.expectNoElement('.reaction')
    page.click('.action-dock__button--react')
    page.click('.md-active .emoji-picker__link:first-child')
    page.pause()
    page.click('.action-dock__button--react')
    page.expectElement('.reaction__emoji', 10000)
  },

  // 'mentions a user': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_discussion')
  //   page.fillIn('.comment-form textarea', '@jennifer')
  //   page.pause()
  //   page.expectText('.mentio-menu', 'Jennifer Grey')
  //   page.click('.mentio-menu md-menu-item')
  //   page.click('.comment-form__submit-button')
  //   page.expectText('.new-comment', '@jennifergrey')
  // },

  'edits a comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form textarea', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.click('.action-dock__button--edit_comment')
    page.fillIn('.edit-comment-form textarea', 'edited comment right thur')
    page.click('.edit-comment-form .comment-form__submit-button')
    page.expectText('.new-comment', 'edited comment right thur')
  },

  'lets_you_view_comment_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_comment_with_versions')
    page.click('.action-dock__button--show_history')
    page.expectText('.revision-history-nav', 'Latest')
    page.expectText('.revision-history-content--markdown del', 'star')
    page.expectText('.revision-history-content--markdown ins', 'moon')
    page.click('.revision-history-nav--previous')
    page.expectText('.revision-history-nav', 'Original')
    page.expectText('.revision-history-content--markdown', 'What star sign are you?')
  },

  'lets_you_view_discussion_revision_history': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_with_versions')
    page.click('.action-dock__button--show_history')
    page.expectText('.revision-history-nav', 'Latest')
    page.expectText('.revision-history-content--header del', 'star')
    page.expectText('.revision-history-content--header ins', 'moon')
    page.click('.revision-history-nav--previous')
    page.expectText('.revision-history-nav', 'Original')
    page.expectText('.revision-history-content--header ins', 'What star sign are you?')
  },

  'deletes a comment': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion')
    page.fillIn('.comment-form textarea', 'original comment right hur')
    page.click('.comment-form__submit-button')
    page.click('.action-dock__button--delete_comment')
    page.click('.confirm-modal__submit')
    page.expectNoText('.activity-card', 'original comment right thur')
  },

  'invites_a_user_to_a_discussion': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_discussion_mailer_new_discussion_email')
    page.click('.thread-mailer__subject a')
    page.expectText('.context-panel__heading', 'go to the moon')
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.fillIn('.comment-form textarea', 'Hello world!')
    page.click('.comment-form__submit-button')
    page.expectText('.thread-item__title', 'Jennifer Grey', 10000)
    page.expectText('.thread-item__body', 'Hello world!')
    page.expectText('.group-theme__name--compact', 'Girdy Dancing Shoes')
    page.ensureSidebar()
    page.expectNoElement('.sidebar__list-item-button--group')
  },

  'invites_an_email_to_a_discussion': (test) => {
    page = pageHelper(test)
    workflow = workflowHelper(test)

    page.loadPath('setup_discussion_mailer_invitation_created_email')
    page.click('.thread-mailer__subject a')
    page.expectValue('.auth-email-form__email input', 'jen@example.com')
    workflow.signUpViaInvitation("Jennifer")
    page.expectText('.context-panel__heading', 'go to the moon', 10000)
    page.expectText('.context-panel__description', 'A description for this discussion')
    page.expectText('.new-comment__body', 'body of the comment')
  },

  'sends_catch_up': (test) => {
    page = pageHelper(test)

    page.loadPath('setup_thread_catch_up')
    page.expectText('.activity-feed', 'body of the comment')
    page.expectText('.activity-feed', 'Patrick Swayze closed the discussion')
  },

  // 'can_fork_a_thread': (test) => {
  //   page = pageHelper(test)
  //
  //   page.loadPath('setup_forkable_discussion')
  //   page.click('.action-dock__button--fork_comment')
  //   page.expectElement('md-checkbox.md-checked')
  //   page.click('.discussion-fork-actions__submit')
  //   page.fillIn('.discussion-form__title-input', 'Forked thread')
  //   page.click('.discussion-form__submit')
  //   page.expectText('.flash-root__message', 'Thread fork created')
  //   page.click('.dismiss-modal-button')
  //   page.expectText('.context-panel__heading', 'Forked thread')
  //   page.expectText('.context-panel__details', 'Forked from What star sign are you?')
  //   page.expectText('.thread-item__directive', 'This is totally on topic!', 8000)
  // }
}
