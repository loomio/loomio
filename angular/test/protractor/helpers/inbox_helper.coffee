module.exports = new class InboxHelper

  load: ->
    browser.get('dev/setup_inbox')

  firstGroup: ->
    element.all(By.css('.inbox-page__group')).first().getText()
