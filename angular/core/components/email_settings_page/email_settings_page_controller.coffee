angular.module('loomioApp').controller 'EmailSettingsPageController', (Records, FormService, User, $location, ModalService, ChangeVolumeForm) ->

  @user = User.current().clone()

  @groupVolume = (group) ->
    group.membershipFor(User.current()).volume

  @defaultSettingsDescription = ->
    "email_settings_page.default_settings.#{User.current().defaultMembershipVolume}_description"

  @changeDefaultMembershipVolume = ->
    ModalService.open ChangeVolumeForm, model: => User.current()

  @editSpecificGroupVolume = (group) ->
    ModalService.open ChangeVolumeForm, model: => group.membershipFor(User.current())

  @submit = FormService.submit @, @user,
    submitFn: Records.users.updateProfile
    flashSuccess: 'email_settings_page.messages.updated'
    successCallback: -> $location.path '/dashboard'

  return
