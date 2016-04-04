angular.module('loomioApp').controller 'EmailSettingsPageController', (Records, FormService, CurrentUser, $location, ModalService, ChangeVolumeForm) ->

  @user = CurrentUser.clone()

  @groupVolume = (group) ->
    group.membershipFor(CurrentUser).volume

  @changeDefaultMembershipVolume = ->
    ModalService.open ChangeVolumeForm, model: => CurrentUser

  @editSpecificGroupVolume = (group) ->
    ModalService.open ChangeVolumeForm, model: => group.membershipFor(CurrentUser)

  @submit = FormService.submit @, @user,
    submitFn: Records.users.updateProfile
    flashSuccess: 'email_settings_page.messages.updated'
    successCallback: -> $location.path '/dashboard'

  return
