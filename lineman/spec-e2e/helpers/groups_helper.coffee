module.exports = new class GroupsHelper
  load: ->
    browser.get('http://localhost:8000/angular_support/setup_group')

  membersList: ->
    element(By.css('.group-member-list'))

  clickStartDiscussionBtn: ->
    element(By.css('.group-page__new-thread a')).click()

  fillInDiscussionTitle: (title)->
    element(By.css('.discussion-form__title-input')).sendKeys(title)

  fillInDiscussionDescription: (description) ->
    element(By.css('.discussion-form__description-input')).sendKeys(description)

  submitDiscussionForm: ->
    element(By.css('.discussion-form__submit')).click()

  discussionTitle: ->
    element(By.css('.thread-context'))
