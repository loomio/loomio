angular.module('loomioApp').controller 'EmailSettingsPageController', (Records, AbilityService, FormService, Session, $location, ModalService, ChangeVolumeForm) ->

  @user = Session.user().clone()

  @groupVolume = (group) ->
    group.membershipFor(Session.user()).volume

  @defaultSettingsDescription = ->
    "email_settings_page.default_settings.#{Session.user().defaultMembershipVolume}_description"

  @changeDefaultMembershipVolume = ->
    ModalService.open ChangeVolumeForm, model: => Session.user()

  @editSpecificGroupVolume = (group) ->
    ModalService.open ChangeVolumeForm, model: => group.membershipFor(Session.user())

  @submit = FormService.submit @, @user,
    submitFn: Records.users.updateProfile
    flashSuccess: 'email_settings_page.messages.updated'
    successCallback: -> $location.path '/dashboard' if AbilityService.isLoggedIn()

  return
