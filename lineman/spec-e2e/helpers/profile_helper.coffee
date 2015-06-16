module.exports = new class ProfileHelper
  load: ->
    browser.get('http://localhost:8000/angular_support/setup_user_profile')

  updateProfile: (name, username, email) ->
    @changeName(name)
    @changeUsername(username)
    @changeEmail(email)
    @submitForm()

  changeName: (text) ->
    element(By.css('#name-field')).sendKeys(text or 'My New name')

  changeUsername: (text) ->
    element(By.css('#username-field')).sendKeys(text or 'mynewusername')

  changeEmail: (text) ->
    element(By.css('#email-field')).sendKeys(text or 'mynew@email.com')

  submitForm: ->
    element(By.css('')).click()