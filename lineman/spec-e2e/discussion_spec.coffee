describe 'Discussion Page', ->

  DiscussionPage = require './helpers/discussion_page.coffee'
  page = new DiscussionPage

  beforeEach ->
    page.load()

  it 'add a comment', ->
    page.addComment('hi this is my comment')
    expect(page.mostRecentComment().getText()).toContain('hi this is my comment')

  it 'reply to a comment', ->
    page.addComment('original comment right heerrr')
    page.replyLinkOnMostRecentComment().click()
    page.addComment('hi this is my comment')
    expect(page.inReplyToOnMostRecentComment().getText()).toContain('in reply to')
    # page.openNotificationDropdown()
    # expect(page.notificationDropdown().getText()).toContain('replied to your comment')

  it 'like a comment', ->
    page.addComment('hi')
    page.likeLinkOnMostRecentComment().click()
    expect(page.likedByOnMostRecentComment().getText()).toContain('You like this.')

  it 'mention a user', ->
    page.enterCommentText('@jennifer')
    expect(page.mentionList().getText()).toContain('Jennifer Grey')
    page.firstMentionOption().click()
    page.submitComment()
    expect(page.mostRecentComment().getText()).toContain('@jennifergrey')
