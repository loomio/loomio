describe 'Discussion Page', ->

  threadHelper = require './helpers/thread_helper.coffee'

  beforeEach ->
    threadHelper.load()

  it 'add a comment', ->
    threadHelper.addComment('hi this is my comment')
    expect(threadHelper.mostRecentComment().getText()).toContain('hi this is my comment')

  it 'reply to a comment', ->
    threadHelper.addComment('original comment right heerrr')
    threadHelper.replyLinkOnMostRecentComment().click()
    threadHelper.addComment('hi this is my comment')
    expect(threadHelper.inReplyToOnMostRecentComment().getText()).toContain('in reply to')
    # threadHelper.openNotificationDropdown()
    # expect(threadHelper.notificationDropdown().getText()).toContain('replied to your comment')

  it 'like a comment', ->
    threadHelper.addComment('hi')
    threadHelper.likeLinkOnMostRecentComment().click()
    expect(threadHelper.likedByOnMostRecentComment().getText()).toContain('You like this.')

  it 'mention a user', ->
    threadHelper.enterCommentText('@jennifer')
    expect(threadHelper.mentionList().getText()).toContain('Jennifer Grey')
    threadHelper.firstMentionOption().click()
    threadHelper.submitComment()
    expect(threadHelper.mostRecentComment().getText()).toContain('@jennifergrey')
