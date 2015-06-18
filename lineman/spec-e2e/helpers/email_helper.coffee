module.exports = new class EmailHelper
  openLastEmail: ->
    browser.driver.get('http://localhost:8000/development/last_email')
    browser.driver.sleep(10)
    browser.driver.findElement(By.css('a')).click()

  firstLink: ->

  clickFirstLink: ->
    @firstLink().click()
