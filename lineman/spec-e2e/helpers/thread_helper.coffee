module.exports = new class ThreadHelper
  load: ->
    browser.get('http://localhost:8000/development/setup_discussion')

  loadWithActiveProposal: ->
    browser.get('http://localhost:8000/development/setup_proposal')

  loadWithActiveProposalWithVotes: ->
    browser.get('http://localhost:8000/development/setup_proposal_with_votes')

  loadWithClosedProposal: ->
    browser.get('http://localhost:8000/development/setup_closed_proposal')

  loadWithSetOutcome: ->
    browser.get('http://localhost:8000/development/setup_closed_proposal_with_outcome')

  addComment: (body) ->
    @enterCommentText(body)
    @submitComment()

  enterCommentText: (body) ->
    element(By.css('.comment-form__comment-field')).sendKeys(body or 'I am a comment')

  submitComment: ->
    element(By.css('.comment-form__submit-button')).click()

  clickThreadItemOptionsButton: ->
    element(By.css('.thread-item__dropdown-button')).click()

  selectEditCommentOption: ->
    element(By.css('.thread-item__edit-link')).click()

  editCommentText: (body) ->
    element(By.css('.edit-comment-form__comment-field')).clear().sendKeys(body)

  submitEditedComment: ->
    element(By.css('.comment-form__submit-btn')).click()

  selectDeleteCommentOption: ->
    element(By.css('.thread-item__delete-link')).click()

  confirmCommentDeletion: ->
    element(By.css('.delete-comment-form__delete-button')).click()

  activityPanel: ->
    element(By.css('.activity-card')).click()

  openNotificationDropdown: ->
    element(By.css('.dropdown-toggle')).click()

  notificationDropdown: ->
    element(By.css('.lmo-navbar__btn--notifications'))

  mostRecentComment: ->
    element.all(By.css('.thread-item--comment')).last()

  replyLinkOnMostRecentComment: ->
    element.all(By.css('.thread-item__action--reply')).last()

  inReplyToOnMostRecentComment: ->
    element.all(By.css('.new-comment__in-reply-to')).last()

  likeLinkOnMostRecentComment: ->
    element.all(By.css('.thread-item__action--like')).last()

  likedByOnMostRecentComment: ->
    element.all(By.css('.thread-item__liked-by')).last()

  flashMessageText: ->
    element(By.css('.flash-container')).getText()

  mentionList: ->
    element(By.css('ul.list-group.user-search'))

  firstMentionOption: ->
    @mentionList().element(By.css('li'))

  clickThreadOptionsDropdownButton: ->
    element(By.css('.thread-context__dropdown-button')).click()

  clickThreadOptionsDropdownEdit: ->
    element(By.css('.thread-context__dropdown-options-edit')).click()

  threadTitleInput: ->
    element(By.css('.discussion-form__title-input')).clear().sendKeys('Edited thread title')

  descriptionInput: ->
    element(By.css('.discussion-form__description-input'))

  clickUpdateThreadButton: ->
    element(By.buttonText('Update thread')).click()

  editThreadTitle: ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownEdit()
    @threadTitleInput().clear().sendKeys('Edited thread title')
    @clickUpdateThreadButton()

  editThreadDescription: ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownEdit()
    @descriptionInput().clear().sendKeys('Edited thread description')
    @clickUpdateThreadButton()

  editThreadTitleAndDescription: ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownEdit()
    @threadTitleInput().clear().sendKeys('New edited thread title')
    @descriptionInput().clear().sendKeys('New edited thread description')
    @clickUpdateThreadButton()

  activityItemList: ->
    element(By.css('.activity-card')).getText()

  openEditThreadForm: ->
    element(By.css('.thread-context__dropdown-button')).click()
    element(By.css('.thread-context__dropdown-options-edit')).click()

  discussionTitle: ->
    element(By.css('.thread-context'))
