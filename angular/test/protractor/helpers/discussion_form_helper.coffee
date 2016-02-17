module.exports = new class DiscussionFormHelper
  fillInTitle: (title)->
    @titleField().clear()
    @titleField().sendKeys(title)

  fillInDescription: (description) ->
    @descriptionField().clear()
    @descriptionField().sendKeys(description)

  titleField: ->
    element(By.css('.discussion-form__title-input'))

  descriptionField: ->
    element(By.css('.discussion-form__description-input'))

  clickSubmit: ->
    element.all(By.css('.discussion-form__submit')).first().click()

  clickUpdate: ->
    element.all(By.css('.discussion-form__update')).first().click()

  clickCancel: ->
    element.all(By.css('.discussion-form__cancel')).first().click()
