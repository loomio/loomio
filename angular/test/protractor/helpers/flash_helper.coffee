module.exports = new class FlashHelper

  flashMessage: ->
    element(By.css('.flash-root__message')).getText()
