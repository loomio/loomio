module.exports = new class EmailSettingsHelper

  load: ->
    browser.get('development/setup_user_email_settings')

  visitEmailSettingsPage: ->
    element(By.css('.navbar-user-options button')).click()
    element(By.css('.navbar-user-options__email-settings-link')).click()

  updateEmailSettings: ->
    @dailySummaryCheckbox().click()
    @onParticipationCheckbox().click()
    @proposalClosingSoonCheckbox().click()
    @mentionedCheckbox().click()
    @submitForm()

  dailySummaryCheckbox: ->
    element(By.css('.email-settings-page__daily-summary'))
    
  onParticipationCheckbox: ->
    element(By.css('.email-settings-page__on-participation'))

  proposalClosingSoonCheckbox: ->
    element(By.css('.email-settings-page__proposal-closing-soon'))

  mentionedCheckbox: ->
     element(By.css('.email-settings-page__mentioned'))

  submitForm: ->
    element(By.css('.email_settings_page__update-button')).click()
