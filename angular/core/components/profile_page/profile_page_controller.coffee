angular.module('loomioApp').controller 'ProfilePageController', ($scope, $rootScope, Records, FormService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm, $translate, Session, AppConfig, DeactivationModal) ->
  $rootScope.$broadcast('currentComponent', { titleKey: 'profile_page.profile', page: 'profilePage'})

  @init = =>
    return unless AbilityService.isLoggedIn()
    @user = Session.user().clone()
    $translate.use(@user.locale)
    @submit = FormService.submit @, @user,
      flashSuccess: 'profile_page.messages.updated'
      submitFn: Records.users.updateProfile
      successCallback: @init
  @init()
  $scope.$on 'updateProfile', => @init()

  @availableLocales = ->
    AppConfig.locales

  @changePicture = ->
    ModalService.open ChangePictureForm

  @changePassword = ->
    ModalService.open ChangePasswordForm

  @deactivateUser = ->
    ModalService.open DeactivationModal

  return
