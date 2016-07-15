module.exports = new class ProfileHelper

  visitUserPage: (username) ->
    browser.get("u/#{username}")

  updateProfile: (name, username, email) ->
    @changeName(name)
    @changeUsername(username)
    @changeEmail(email)
    @submitForm()

  nameInput: ->
    element(By.css('.profile-page__name-input'))

  usernameInput: ->
    element(By.css('.profile-page__username-input'))

  emailInput: ->
    element(By.css('.profile-page__email-input'))

  changeName: (text) ->
    @nameInput().clear().sendKeys(text or 'My New name')

  changeUsername: (text) ->
    @usernameInput().clear().sendKeys(text or 'mynewusername')

  changeEmail: (text) ->
    @emailInput().clear().sendKeys(text or 'mynew@email.com')

  submitForm: ->
    element(By.css('.profile-page__update-button')).click()

  nameText: ->
    element(By.css('.user-page__name')).getText()

  usernameText: ->
    element(By.css('.user-page__username')).getText()

  groupsText: ->
    element(By.css('.user-page__groups')).getText()
