module.exports = new class InboxHelper

  load: ->
    browser.get('http://localhost:8000/development/setup_inbox')

  firstGroup: ->
    element.all(By.css('.inbox-page__group')).first().getText()

  lastGroup: ->
    element.all(By.css('.inbox-page__group')).last().getText()

  anyThreads: ->
    element(By.css('.inbox-page__threads')).getText()
