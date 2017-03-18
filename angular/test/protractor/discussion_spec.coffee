describe 'Discussion Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  discussionForm = require './helpers/discussion_form_helper.coffee'
  threadPage = require './helpers/thread_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'
  emailhelper = require './helpers/email_helper.coffee'
  staticPage = require './helpers/static_page_helper.coffee'
  page = require './helpers/page_helper.coffee'

  describe 'starting a thread via start menu', ->
    it 'preselects current group', ->
      page.loadPath 'setup_dashboard'
      page.click '.sidebar__list-item-button--muted'
      page.clickLast '.thread-preview__link'
      page.click '.start-menu__start-button'
      page.click '.start-menu__startThread'
      page.expectText '.discussion-form__group-select', 'Muted Point Blank'

  describe 'viewing while logged out', ->
    it 'should display content for a public thread', ->
      groupsHelper.loadPath('view_open_group_as_visitor')
      page.expectText('.group-theme__name', 'Open Dirty Dancing Shoes')
      page.expectText('.thread-previews-container', 'I carried a watermelon')
      page.expectText('.navbar__right', 'Log In')
      page.click('.thread-preview__link')
      page.expectText('.context-panel', 'I carried a watermelon')

    it 'should display timestamps on content', ->
      page.loadPath('view_open_group_as_non_member')
      page.click('.thread-preview__link')
      page.expectElement('.timeago')

  describe 'edit thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'lets you edit title, context and privacy', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'
      page.fillIn('.discussion-form__title-input', 'better title')
      page.fillIn('.discussion-form__description-input', 'improved description')
      page.click('.discussion-form__private')
      page.click('.discussion-form__update')
      page.expectText('.context-panel', 'better title')
      page.expectText('.context-panel', 'improved description')
      page.expectText('.context-panel', 'Private')
      page.expectText('.thread-item__title', 'updated the thread title, context and privacy')

    it 'does not store cancelled thread info', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'

      page.fillIn('.discussion-form__title-input', 'dumb title')
      page.fillIn('.discussion-form__description-input', 'rubbish description')

      page.click('.discussion-form__cancel')
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'

      page.expectNoText('.discussion-form__title-input', 'dumb title')
      page.expectNoText('.discussion-form__description-input', 'rubbish description')

    it 'lets you view thread revision history', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--edit'
      page.fillIn '.discussion-form__title-input', 'Revised title'
      page.fillIn '.discussion-form__description-input', 'Revised description'
      page.click '.discussion-form__update'
      page.click '.context-panel__edited'
      page.expectText '.revision-history-modal__body', 'Revised title'
      page.expectText '.revision-history-modal__body', 'Revised description'
      page.expectText '.revision-history-modal__body', 'What star sign are you?'

  describe 'muting and unmuting a thread', ->
    it 'lets you mute and unmute', ->
      page.loadPath 'setup_multiple_discussions'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--mute'
      page.click '.mute-explanation-modal__mute-thread'
      page.expectFlash 'Thread muted'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--unmute'
      page.expectFlash 'Thread unmuted'

  describe 'move thread', ->
    it 'lets you move a thread', ->
      page.loadPath 'setup_multiple_discussions'
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--move'
      page.click '.move-thread-form__group-dropdown'
      element(By.cssContainingText('option', 'Point Break')).click()
      page.click '.move-thread-form'
      page.click '.move-thread-form__submit'
      page.expectFlash 'Thread has been moved to Point Break'
      page.expectText '.thread-item__title', 'Patrick Swayze moved the thread from Dirty Dancing Shoes'
      page.expectText '.group-theme__name--compact','Point Break'

  describe 'delete thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'lets coordinators and thread authors delete threads', ->
      threadPage.openThreadOptionsDropdown()
      threadPage.selectDeleteThreadOption()
      threadPage.confirmThreadDeletion()
      expect(flashHelper.flashMessage()).toContain('Thread deleted')
      expect(groupsHelper.groupName().isPresent()).toBe(true)
      expect(groupsHelper.groupPage()).not.toContain('What star sign are you?')

  describe 'changing thread email settings', ->
    beforeEach ->
      page.loadPath('setup_discussion')
    it 'lets you change thread volume', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--email-settings',
                 '#volume-loud',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed activity in this thread.'

    it 'lets you change the volume for all threads in the group', ->
      page.click '.context-panel__dropdown-button',
                 '.context-panel__dropdown-options--email-settings',
                 '#volume-loud',
                 '.change-volume-form__apply-to-all',
                 '.change-volume-form__submit'
      page.expectFlash 'You will be emailed all activity in this group.'

  describe 'joining the group', ->
    it 'allows logged in users to join a group and comment', ->
      page.loadPath 'view_open_group_as_non_member'
      page.click '.thread-preview__link'
      page.click '.join-group-button__join-group'
      page.expectFlash 'You are now a member of Open Dirty Dancing Shoes'

      page.fillIn '.comment-form__comment-field', 'I am new!'
      page.click '.comment-form__submit-button'
      page.expectFlash 'Comment added'

    it 'allows logged in users to request to join a closed group', ->
      page.loadPath 'view_closed_group_as_non_member'
      page.click '.thread-preview__link'
      page.click '.join-group-button__ask-to-join-group'
      page.click '.membership-request-form__submit-btn'
      page.expectFlash 'You have requested membership to Closed Dirty Dancing Shoes'

  describe 'signing in', ->
    it 'allows logged out users to log in and comment', ->
      page.loadPath 'view_open_group_as_visitor'
      page.click '.thread-preview__link'
      page.click '.comment-form__sign-in-btn'
      page.fillIn '#user-email', 'jennifer_grey@example.com'
      page.fillIn '#user-password', 'gh0stmovie'
      page.click '.sign-in-form__submit-button'
      page.waitForReload()
      page.expectFlash 'Signed in successfully'

      page.fillIn '.comment-form__comment-field', 'I am new!'
      page.click '.comment-form__submit-button'
      page.expectFlash 'Comment added'

  describe 'commenting', ->
    beforeEach ->
      page.loadPath('setup_discussion')
      browser.driver.manage().window().setSize(1280, 1024);

    it 'adds a comment', ->
      threadPage.addComment('hi this is my comment')
      expect(threadPage.mostRecentComment()).toContain('hi this is my comment')

    it 'can add emojis', ->
      page.fillIn '.comment-form__comment-field', 'Here is a dragon!'
      page.click '.emoji-picker__toggle'
      page.fillIn '.emoji-picker__search', 'drag'
      page.clickFirst '.emoji-picker__icon'
      page.click '.comment-form__submit-button'
      page.expectText '.thread-item__body','Here is a dragon!'
      page.expectElement '.thread-item__body img'

    it 'replies to a comment', ->
      threadPage.addComment('original comment right heerrr')
      threadPage.replyLinkOnMostRecentComment().click()
      threadPage.addComment('hi this is my comment')
      expect(threadPage.inReplyToOnMostRecentComment()).toContain('in reply to')
      expect(flashHelper.flashMessage()).toContain('Patrick Swayze notified of reply')

    it 'likes a comment', ->
      threadPage.addComment('hi')
      threadPage.likeLinkOnMostRecentComment().click()
      expect(threadPage.likedByOnMostRecentComment()).toContain('You like this.')

    it 'mentions a user', ->
      threadPage.enterCommentText('@jennifer')
      expect(threadPage.mentionList().getText()).toContain('Jennifer Grey')
      threadPage.firstMentionOption().click()
      threadPage.submitComment()
      expect(threadPage.mostRecentComment()).toContain('@jennifergrey')

    it 'edits a comment', ->
      threadPage.addComment('original comment right hur')
      threadPage.clickThreadItemOptionsButton()
      threadPage.selectEditCommentOption()
      threadPage.editCommentText('edited comment right thur')
      threadPage.submitEditedComment()
      expect(threadPage.mostRecentComment()).toContain('edited comment right thur')

    it 'lets you view comment revision history', ->
      page.fillIn '.comment-form__comment-field', 'Comment!'
      page.click '.comment-form__submit-button'
      page.click '.thread-item__dropdown-button',
                 '.thread-item__edit-link'
      page.fillIn '.edit-comment-form__comment-field', 'Revised comment!'
      page.click  '.comment-form__submit-btn'
      browser.sleep(2000)
      page.click '.thread-item__action--view-edits'
      page.expectText '.revision-history-modal__body', 'Revised comment!'
      page.expectText '.revision-history-modal__body', 'Comment!'

    it 'deletes a comment', ->
      threadPage.addComment('original comment right hur')
      threadPage.clickThreadItemOptionsButton()
      threadPage.selectDeleteCommentOption()
      threadPage.confirmCommentDeletion()
      expect(threadPage.activityPanel()).not.toContain('original comment right thur')

  xdescribe 'following a link in a thread email', ->
    it 'successfully takes you to relevant comment', ->
      page.loadPath 'setup_reply_email'
      emailhelper.openLastEmail()
      staticPage.click 'a'
      page.expectText '.activity-card', 'Hello Jennifer'
