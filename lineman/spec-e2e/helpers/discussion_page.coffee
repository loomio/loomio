module.exports = class DiscussionPage
  load: ->
    browser.get('http://localhost:8000/angular_support/setup_for_add_comment')

  loadWithActiveProposal: ->
    browser.get('http://localhost:8000/angular_support/setup_for_vote_on_proposal')

  addComment: (body) ->
    @enterCommentText(body)
    @submitComment()

  enterCommentText: (body) ->
    element(By.css('#comment-field')).sendKeys(body or 'I am a comment')

  submitComment: ->
    element(By.css('#post-comment-btn')).click()

  openNotificationDropdown: ->
    element(By.css('.dropdown-toggle')).click()

  notificationDropdown: ->
    element(By.css('.lmo-navbar__btn--notifications'))

  mostRecentComment: ->
    element.all(By.css('.thread-item--comment')).last()

  replyLinkOnMostRecentComment: ->
    element.all(By.css('.thread-actions__reply')).last()

  inReplyToOnMostRecentComment: ->
    element.all(By.css('.new-comment__in-reply-to')).last()

  likeLinkOnMostRecentComment: ->
    element.all(By.css('.thread-actions__like')).last()

  likedByOnMostRecentComment: ->
    element.all(By.css('.thread-liked-by-sentence')).last()

  flashMessageText: ->
    element(By.css('.flash-container')).getText()

  mentionList: ->
    element(By.css('ul.list-group.user-search'))
    
  firstMentionOption: ->
    @mentionList().element(By.css('li'))
