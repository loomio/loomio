module.exports = new class ThreadHelper
  load: ->
    browser.get('development/setup_discussion')

  loadWithPublicContent: ->
    browser.get('development/setup_public_group_with_public_content')

  loadWithActiveProposal: ->
    browser.get('development/setup_proposal')

  loadWithActiveProposalWithVotes: ->
    browser.get('development/setup_proposal_with_votes')

  loadWithClosedProposal: ->
    browser.get('development/setup_closed_proposal')

  loadWithSetOutcome: ->
    browser.get('development/setup_closed_proposal_with_outcome')

  loadWithMultipleDiscussions: ->
    browser.get('development/setup_multiple_discussions')

  addComment: (body) ->
    @enterCommentText(body)
    @submitComment()

  commentForm: ->
    element(By.css('.comment-form__comment-field'))

  enterCommentText: (body) ->
    @commentForm().sendKeys(body or 'I am a comment')

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
    element(By.css('.activity-card')).getText()

  openNotificationDropdown: ->
    element(By.css('.dropdown-toggle')).click()

  notificationDropdown: ->
    element(By.css('.lmo-navbar__btn--notifications'))

  mostRecentComment: ->
    element.all(By.css('.thread-item--comment')).last().getText()

  replyLinkOnMostRecentComment: ->
    element.all(By.css('.thread-item__action--reply')).last()

  inReplyToOnMostRecentComment: ->
    element.all(By.css('.new-comment__in-reply-to')).last().getText()

  likeLinkOnMostRecentComment: ->
    element.all(By.css('.thread-item__action--like')).last()

  likedByOnMostRecentComment: ->
    element.all(By.css('.thread-item__liked-by')).last().getText()

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

  clickThreadOptionsDropdownMove: ->
    element(By.css('.thread-context__dropdown-options-move')).click()

  threadTitleInput: ->
    element(By.css('.discussion-form__title-input')).clear().sendKeys('Edited thread title')

  threadDestinationInput: ->
    element(By.css('.move-thread-form__group-dropdown'))

  contextInput: ->
    element(By.css('.discussion-form__description-input'))

  clickUpdateThreadButton: ->
    element(By.buttonText('Update thread')).click()

  clickMoveThreadButton: ->
    element(By.buttonText('Move thread')).click()

  editThreadTitle: ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownEdit()
    @threadTitleInput().clear().sendKeys('Edited thread title')
    @clickUpdateThreadButton()

  editThreadContext: ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownEdit()
    @contextInput().clear().sendKeys('Edited thread context')
    @clickUpdateThreadButton()

  editThreadTitleAndContext: ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownEdit()
    @threadTitleInput().clear().sendKeys('New edited thread title')
    @contextInput().clear().sendKeys('New edited thread context')
    @clickUpdateThreadButton()

  moveThread: (groupName) ->
    @clickThreadOptionsDropdownButton()
    @clickThreadOptionsDropdownMove()
    @threadDestinationInput().sendKeys(groupName)
    @clickMoveThreadButton()

  activityItemList: ->
    element(By.css('.activity-card')).getText()

  openThreadOptionsDropdown: ->
    element(By.css('.thread-context__dropdown-button')).click()

  openEditThreadForm: ->
    @openThreadOptionsDropdown()
    element(By.css('.thread-context__dropdown-options-edit')).click()

  groupTitle: ->
    element(By.css('.group-theme__name--compact')).getText()

  discussionTitle: ->
    element(By.css('.thread-context')).getText()

  selectDeleteThreadOption: ->
    element(By.css('.thread-context__dropdown-options-delete')).click()

  confirmThreadDeletion: ->
    element(By.css('.delete_thread_form__submit')).click()

  threadOptionsDropdown: ->
    element(By.css('.thread-context__dropdown'))

  volumeOptions: ->
    element(By.css('.notification-volume'))

  angularFeedbackCard: ->
    element(By.css('#angular-feedback-card'))

  threadVolumeCard: ->
    element(By.css('.thread-volume-card')).getText()

  clickChangeInThreadVolumeCard: ->
    element(By.css('.thread-volume-card__change-volume-link')).click()

  changeThreadVolumeToLoud: ->
    element(By.id('volume-loud')).click()

  submitChangeVolumeForm: ->
    element(By.css('.change-volume-form__submit')).click()

  signInButton: ->
    element(By.css('.lmo-navbar__sign-in')).getText()
