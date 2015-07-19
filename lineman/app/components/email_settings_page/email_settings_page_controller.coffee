angular.module('loomioApp').controller 'EmailSettingsPageController', (Records, FormService, CurrentUser, $location) ->

  @user = CurrentUser.clone()

  @submit = FormService.submit @, @user,
    submitFn: Records.users.updateProfile
    flashSuccess: 'email_settings_page.messages.updated'
    successCallback: -> $location.path '/dashboard'

  return
