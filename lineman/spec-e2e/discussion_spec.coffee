describe 'Discussion Page', ->

  groupsHelper = require './helpers/groups_helper.coffee'
  discussionForm = require './helpers/discussion_form_helper.coffee'
  threadPage = require './helpers/thread_helper.coffee'

  beforeEach ->
    threadPage.load()

  describe 'edit thread', ->
    it 'lets you edit title and context', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('better title')
      discussionForm.fillInDescription("improved description")
      discussionForm.clickUpdate()
      expect(threadPage.discussionTitle().getText()).toContain('better title')
      expect(threadPage.discussionTitle().getText()).toContain("improved description")

    it 'lets you accidentally cancel then save', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('even better title')
      discussionForm.fillInDescription("more improved description")
      discussionForm.clickCancel()
      alert = browser.switchTo().alert()
      alert.dismiss()
      discussionForm.clickUpdate()
      expect(threadPage.discussionTitle().getText()).toContain('even better title')
      expect(threadPage.discussionTitle().getText()).toContain("more improved description")

    it 'confirms you really want to cancel', ->
      threadPage.openEditThreadForm()
      discussionForm.fillInTitle('dumb title')
      discussionForm.fillInDescription("rubbish description")
      discussionForm.clickCancel()
      alert = browser.switchTo().alert()
      alert.accept()
      expect(threadPage.discussionTitle().getText()).toContain('What star sign are you?')

  it 'adds a comment', ->
    threadPage.addComment('hi this is my comment')
    expect(threadPage.mostRecentComment().getText()).toContain('hi this is my comment')

  it 'replies to a comment', ->
    threadPage.addComment('original comment right heerrr')
    threadPage.replyLinkOnMostRecentComment().click()
    threadPage.addComment('hi this is my comment')
    expect(threadPage.inReplyToOnMostRecentComment().getText()).toContain('in reply to')
    # threadPage.openNotificationDropdown()
    # expect(threadPage.notificationDropdown().getText()).toContain('replied to your comment')

  it 'likes a comment', ->
    threadPage.addComment('hi')
    threadPage.likeLinkOnMostRecentComment().click()
    expect(threadPage.likedByOnMostRecentComment().getText()).toContain('You like this.')

  it 'mentions a user', ->
    threadPage.enterCommentText('@jennifer')
    expect(threadPage.mentionList().getText()).toContain('Jennifer Grey')
    threadPage.firstMentionOption().click()
    threadPage.submitComment()
    expect(threadPage.mostRecentComment().getText()).toContain('@jennifergrey')

  it 'edits a comment', ->
    threadPage.addComment('original comment right hur')
    threadPage.clickThreadItemOptionsButton()
    threadPage.selectEditCommentOption()
    threadPage.editCommentText('edited comment right thur')
    threadPage.submitEditedComment()
    expect(threadPage.mostRecentComment().getText()).toContain('edited comment right thur')

  it 'deletes a comment', ->
    threadPage.addComment('original comment right hur')
    threadPage.clickThreadItemOptionsButton()
    threadPage.selectDeleteCommentOption()
    threadPage.confirmCommentDeletion()
    expect(threadPage.activityPanel().getText()).not.toContain('original comment right thur')
