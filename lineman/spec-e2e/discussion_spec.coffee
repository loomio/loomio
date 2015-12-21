describe 'Discussion Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  discussionForm = require './helpers/discussion_form_helper.coffee'
  threadPage = require './helpers/thread_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'
  page = require './helpers/page_helper.coffee'

  describe 'viewing while logged out', ->
    xit 'should display content for a public thread', ->
      groupsHelper.loadPath('view_open_group_as_visitor')
      groupsHelper.clickFirstThread()
      expect(threadPage.discussionTitle()).toContain('I carried a watermelon')
      expect(threadPage.signInButton()).toContain('Sign In')

  describe 'edit thread', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'lets you edit title and context', ->
      page.click '.thread-context__dropdown-button',
                 '.thread-context__dropdown-options-edit'
      page.fillIn('.discussion-form__title-input', 'better title')
      page.fillIn('.discussion-form__description-input', 'improved description')
      page.click('.discussion-form__update')
      page.expectText('.thread-context', 'better title')
      page.expectText('.thread-context', "improved description")

    it 'does not store cancelled thread info', ->
      page.click '.thread-context__dropdown-button',
                 '.thread-context__dropdown-options-edit'

      page.fillIn('.discussion-form__title-input', 'dumb title')
      page.fillIn('.discussion-form__description-input', 'rubbish description')

      page.click('.discussion-form__cancel')
      page.click '.thread-context__dropdown-button',
                 '.thread-context__dropdown-options-edit'

      page.expectNoText('.discussion-form__title-input', 'dumb title')
      page.expectNoText('.discussion-form__description-input', 'rubbish description')

  describe 'move thread', ->
    it 'lets you move a thread', ->
      page.loadPath 'setup_multiple_discussions'
      page.click '.thread-context__dropdown-button',
                 '.thread-context__dropdown-options-move'

      page.click '.move-thread-form__group-dropdown'
      element(By.cssContainingText('option', 'Point Break')).click();
      page.click '.move-thread-form__submit'

      page.expectText '.group-theme__name--compact','Point Break'
      page.expectFlash 'Thread has been moved to Point Break'

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

  describe 'changing thread volume', ->
    beforeEach ->
      page.loadPath('setup_discussion')

    it 'lets you change thread notification volume', ->
      expect(threadPage.threadVolumeCard()).toContain('Email proposals')
      threadPage.clickChangeInThreadVolumeCard()
      threadPage.changeThreadVolumeToLoud()
      threadPage.submitChangeVolumeForm()
      expect(threadPage.threadVolumeCard()).toContain('Email everything')

  describe 'commenting', ->
    beforeEach ->
      page.loadPath('setup_discussion')
      browser.driver.manage().window().setSize(1280, 1024);

    it 'adds a comment', ->
      threadPage.addComment('hi this is my comment')
      expect(threadPage.mostRecentComment()).toContain('hi this is my comment')

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

    it 'deletes a comment', ->
      threadPage.addComment('original comment right hur')
      threadPage.clickThreadItemOptionsButton()
      threadPage.selectDeleteCommentOption()
      threadPage.confirmCommentDeletion()
      expect(threadPage.activityPanel()).not.toContain('original comment right thur')

    xit 'hides member actions from visitors', ->
      threadPage.loadWithPublicContent()
      expect(threadPage.commentForm().isPresent()).toBe(false)
      expect(threadPage.threadOptionsDropdown().isPresent()).toBe(false)
      expect(threadPage.volumeOptions().isPresent()).toBe(false)
