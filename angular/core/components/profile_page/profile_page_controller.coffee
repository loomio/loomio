angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, Records, FormService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm, $translate, CurrentUser, AppConfig) ->
  @user = CurrentUser

  @init = =>
    $translate.use(@user.locale)
  @init()

  @availableLocales = ->
    AppConfig.locales

  @submit = FormService.submit @, @user,
    flashSuccess: 'profile_page.messages.updated'
    submitFn: Records.users.updateProfile
    successCallback: @init

  @changePicture = ->
    ModalService.open ChangePictureForm

  @changePassword = ->
    ModalService.open ChangePasswordForm

  @deactivateUser = ->
    ModalService.open DeactivateUserForm

  @canDeactivateUser = ->
    AbilityService.canDeactivateUser()

  return
