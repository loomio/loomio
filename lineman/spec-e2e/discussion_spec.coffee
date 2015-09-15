describe 'Discussion Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  discussionForm = require './helpers/discussion_form_helper.coffee'
  threadPage = require './helpers/thread_helper.coffee'
  flashHelper = require './helpers/flash_helper.coffee'

  beforeEach ->
    threadPage.load()

  describe 'edit thread', ->
    it 'lets you edit title and context', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('better title')
      discussionForm.fillInDescription("improved description")
      discussionForm.clickUpdate()
      expect(threadPage.discussionTitle()).toContain('better title')
      expect(threadPage.discussionTitle()).toContain("improved description")

    it 'lets you accidentally cancel then save', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('even better title')
      discussionForm.fillInDescription("more improved description")
      discussionForm.clickCancel()
      alert = browser.switchTo().alert()
      alert.dismiss()
      discussionForm.clickUpdate()
      expect(threadPage.discussionTitle()).toContain('even better title')
      expect(threadPage.discussionTitle()).toContain("more improved description")

    it 'confirms you really want to cancel', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('dumb title')
      discussionForm.fillInDescription("rubbish description")
      discussionForm.clickCancel()
      alert = browser.switchTo().alert()
      alert.accept()
      expect(threadPage.discussionTitle()).toContain('What star sign are you?')

  describe 'delete thread', ->

    it 'lets coordinators and thread authors delete threads', ->
      threadPage.openThreadOptionsDropdown()
      threadPage.selectDeleteThreadOption()
      threadPage.confirmThreadDeletion()
      expect(flashHelper.flashMessage()).toContain('Thread deleted')
      expect(groupsHelper.groupName().isPresent()).toBe(true)
      expect(groupsHelper.groupPage()).not.toContain('What star sign are you?')

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
