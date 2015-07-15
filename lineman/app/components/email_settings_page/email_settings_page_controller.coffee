angular.module('loomioApp').controller 'EmailSettingsPageController', (Records, FlashService, CurrentUser, $location) ->

  @user = CurrentUser.clone()

  @submit = ->
    @isDisabled = true
    Records.users.updateProfile(@user).then =>
      @user = Records.users.find(CurrentUser.id).clone()
      $location.path "/dashboard"
      FlashService.success('email_settings_page.messages.updated')

  return
