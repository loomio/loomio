angular.module('loomioApp').controller 'ProfilePageController', ($scope, $rootScope, Records, FormService, $location, AbilityService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm, Session, AppConfig, DeactivationModal) ->
  $rootScope.$broadcast('currentComponent', { titleKey: 'profile_page.profile', page: 'profilePage'})

  @showHelpTranslate = ->
    AppConfig.features.help_link

  @init = =>
    return unless AbilityService.isLoggedIn()
    @user = Session.user().clone()
    Session.setLocale(@user.locale)
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
