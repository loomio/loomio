AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ setLocale } = require 'angular/helpers/user.coffee'

angular.module('loomioApp').controller 'ProfilePageController', ($scope, $location, $translate, $rootScope, FormService, ModalService) ->
  $rootScope.$broadcast('currentComponent', { titleKey: 'profile_page.profile', page: 'profilePage'})

  @showHelpTranslate = ->
    AppConfig.features.app.help_link

  @init = =>
    return unless AbilityService.isLoggedIn()
    @user = Session.user().clone()
    setLocale($translate)
    @submit = FormService.submit @, @user,
      flashSuccess: 'profile_page.messages.updated'
      submitFn: Records.users.updateProfile
      successCallback: @init

  @init()
  $scope.$on 'updateProfile', => @init()

  @availableLocales = ->
    AppConfig.locales

  @changePicture = ->
    ModalService.open 'ChangePictureForm'

  @changePassword = ->
    ModalService.open 'ChangePasswordForm'

  @deactivateUser = ->
    ModalService.open 'DeactivationModal'

  return
