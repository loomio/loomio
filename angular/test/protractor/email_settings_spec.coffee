describe 'Email settings', ->
  page = require './helpers/page_helper.coffee'
  emailSettingsHelper = require './helpers/email_settings_helper.coffee'

  beforeEach ->
    emailSettingsHelper.load()
    emailSettingsHelper.visitEmailSettingsPage()

  it "successfully updates a user's email settings", ->
    emailSettingsHelper.updateEmailSettings()
    emailSettingsHelper.visitEmailSettingsPage()
    expect(emailSettingsHelper.dailySummaryCheckbox().isSelected()).toBeTruthy()
    expect(emailSettingsHelper.onParticipationCheckbox().isSelected()).toBeTruthy()
    expect(emailSettingsHelper.proposalClosingSoonCheckbox().isSelected()).toBeTruthy()
    expect(emailSettingsHelper.mentionedCheckbox().isSelected()).toBeTruthy()

  it 'redirects the user to the dashboard with flash when settings are updated', ->
    emailSettingsHelper.updateEmailSettings()
    page.expectFlash('Email settings updated')
    page.expectElement('.dashboard-page')
