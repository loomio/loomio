angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, Records, FormService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm, $translate) ->
  @init = ->
    @user = Records.users.find(window.Loomio.currentUserId)
    $translate.use(@user.locale)

  @init()

  @availableLocales = ->
    window.Loomio.locales

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
