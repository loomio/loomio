angular.module('loomioApp').controller 'EmailSettingsPageController', (Records, AbilityService, FormService, Session, $location, ModalService, ChangeVolumeForm) ->

  @user = Session.current().clone()

  @groupVolume = (group) ->
    group.membershipFor(Session.current()).volume

  @defaultSettingsDescription = ->
    "email_settings_page.default_settings.#{Session.current().defaultMembershipVolume}_description"

  @changeDefaultMembershipVolume = ->
    ModalService.open ChangeVolumeForm, model: => Session.current()

  @editSpecificGroupVolume = (group) ->
    ModalService.open ChangeVolumeForm, model: => group.membershipFor(Session.current())

  @submit = FormService.submit @, @user,
    submitFn: Records.users.updateProfile
    flashSuccess: 'email_settings_page.messages.updated'
    successCallback: -> $location.path '/dashboard' if AbilityService.isLoggedIn()

  return
