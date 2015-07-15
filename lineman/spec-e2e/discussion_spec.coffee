describe 'Discussion Page', ->

  threadHelper = require './helpers/thread_helper.coffee'

  beforeEach ->
    threadHelper.load()

  it 'adds a comment', ->
    threadHelper.addComment('hi this is my comment')
    expect(threadHelper.mostRecentComment().getText()).toContain('hi this is my comment')

  it 'replies to a comment', ->
    threadHelper.addComment('original comment right heerrr')
    threadHelper.replyLinkOnMostRecentComment().click()
    threadHelper.addComment('hi this is my comment')
    expect(threadHelper.inReplyToOnMostRecentComment().getText()).toContain('in reply to')
    # threadHelper.openNotificationDropdown()
    # expect(threadHelper.notificationDropdown().getText()).toContain('replied to your comment')

  it 'likes a comment', ->
    threadHelper.addComment('hi')
    threadHelper.likeLinkOnMostRecentComment().click()
    expect(threadHelper.likedByOnMostRecentComment().getText()).toContain('You like this.')

  it 'mentions a user', ->
    threadHelper.enterCommentText('@jennifer')
    expect(threadHelper.mentionList().getText()).toContain('Jennifer Grey')
    threadHelper.firstMentionOption().click()
    threadHelper.submitComment()
    expect(threadHelper.mostRecentComment().getText()).toContain('@jennifergrey')

  it 'edits a comment', ->
    threadHelper.addComment('original comment right hur')
    threadHelper.clickThreadItemOptionsButton()
    threadHelper.selectEditCommentOption()
    threadHelper.editCommentText('edited comment right thur')
    threadHelper.submitEditedComment()
    expect(threadHelper.mostRecentComment().getText()).toContain('edited comment right thur')

  it 'deletes a comment', ->
    threadHelper.addComment('original comment right hur')
    threadHelper.clickThreadItemOptionsButton()
    threadHelper.selectDeleteCommentOption()
    threadHelper.confirmCommentDeletion()
    expect(threadHelper.activityPanel().getText()).not.toContain('original comment right thur')

