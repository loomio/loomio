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
    page.mostRecentComment().element(By.css('.cuke-comment-reply-btn')).click()
    page.addComment('hi this is my comment')
    expect(page.mostRecentComment().element(By.css('.cuke-in-reply-to')).getText()).toContain('in reply to')
    page.openNotificationDropdown()
    expect(page.notificationDropdown().getText()).toContain('replied to your comment')

  it 'like a comment', ->
    page.addComment('hi')
    page.mostRecentComment().element(By.css('.cuke-comment-like-btn')).click()
    expect(element(By.css('.thread-liked-by-sentence')).getText()).toContain('You like this.')

  iit 'mention a user', ->
    page.enterCommentText('@max')
    expect(page.mentionList().toContain('Max Von Sydow')
    page.firstMention().click()
    page.submitComment()
    expect(page.mostRecentComment().getText()).toContain('@maxvonsydow')
