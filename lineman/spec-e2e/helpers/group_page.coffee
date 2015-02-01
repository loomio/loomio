module.exports = class GroupPage

  loadForInvitations: ->
    browser.get('http://localhost:8000/angular_support/setup_for_invite_people')

  invitePeopleLink: ->
    element(By.css('.cuke-group-invite-people'))

  invitePeopleField: ->
    element(By.css('.cuke-group-invite-people-field'))

  invitePerson: (fragment) ->
    @invitePeopleLink().click()
    element(By.model('fragment')).sendKeys(fragment)
    browser.wait => @firstInvitable().isPresent()
    @firstInvitable().click()

  sendInvitations: ->
    element(By.css('.cuke-group-invitation-submit')).click()

  firstInvitable: ->
    element(By.css('.cuke-group-invitable-option'))

  groupHasMember: (username) ->
    element(By.css(".group-member-list-avatar[data-username=#{username}]")).isPresent()