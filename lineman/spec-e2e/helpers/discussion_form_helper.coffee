module.exports = new class DiscussionFormHelper
  fillInTitle: (title)->
    element(By.css('.discussion-form__title-input')).clear()
    element(By.css('.discussion-form__title-input')).sendKeys(title)

  fillInDescription: (description) ->
    element(By.css('.discussion-form__description-input')).clear()
    element(By.css('.discussion-form__description-input')).sendKeys(description)

  clickSubmit: ->
    element.all(By.css('.discussion-form__submit')).first().click()

  clickUpdate: ->
    element.all(By.css('.discussion-form__update')).first().click()

  clickCancel: ->
    element.all(By.css('.discussion-form__cancel')).first().click()

