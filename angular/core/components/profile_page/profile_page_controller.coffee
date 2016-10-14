angular.module('loomioApp').controller 'ProfilePageController', ($rootScope, Records, FormService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm, $translate, Session, AppConfig, DeactivationModal) ->
  $rootScope.$broadcast('currentComponent', { page: 'profilePage'})


  @init = =>
    return unless AbilityService.isLoggedIn()
    @user = Session.user()
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
    ModalService.open DeactivationModal

  return
