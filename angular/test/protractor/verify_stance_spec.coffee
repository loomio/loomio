_ = require('lodash')

xdescribe 'Verify Stances', ->
  page = require './helpers/page_helper.coffee'

  describe 'private poll vote as logged out existing user, then verify vote', ->
    it "creates unverified stance then assigns it to verified user", ->
      page.loadPath('polls/test_invitation_to_vote_in_poll')

      page.click('.poll-mailer__poll-title')
      page.sleep(2000)
      page.fillIn ".poll-common-participant-form__name", "Jimmy Unverified"
      page.clickFirst ".poll-common-vote-form__option"
      page.click ".poll-common-vote-form__submit"

      page.expectFlash "Vote created"
      page.expectElement ".verify-email-notice"

      page.loadPath('last_email')
      page.clickFirst("a")
      page.sleep(2000)

      page.expectText('.sidebar__user-name', 'Verified User')
      page.click ".verify-stances-page__verify"
      page.click '.auth-signin-form__submit'
      page.expectFlash "Vote verified"

  describe 'private poll vote as logged out new user, then verify vote', ->
    it "creates unverified stance then verifies the user", ->
      page.loadPath('polls/test_invitation_to_vote_in_poll')
      page.click('.poll-mailer__poll-title')
      page.sleep(3000)
      page.fillIn ".poll-common-participant-form__name", "Jimmy New Person"
      page.fillIn ".poll-common-participant-form__email", "#{_.random(999999999)}@example.com"
      page.clickFirst ".poll-common-vote-form__option"
      page.click ".poll-common-vote-form__submit"

      page.expectFlash "Vote created"
      page.expectElement ".verify-email-notice"

      page.loadPath('last_email')
      page.clickFirst("a")
      page.sleep(3000)

      page.click '.auth-signin-form__submit'
      page.expectText('.sidebar__user-name', 'Jimmy New Person')
      page.expectNoElement ".verify-email-notice"
