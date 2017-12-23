AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').controller 'ProfilePageController', ($scope, $location, $translate, $rootScope, FormService, ModalService, ChangePictureForm, ChangePasswordForm, DeactivateUserForm, DeactivationModal) ->
  $rootScope.$broadcast('currentComponent', { titleKey: 'profile_page.profile', page: 'profilePage'})

  @showHelpTranslate = ->
    AppConfig.features.app.help_link

  @init = =>
    return unless AbilityService.isLoggedIn()
    @user = Session.user().clone()
    @setLocale()
    @submit = FormService.submit @, @user,
      flashSuccess: 'profile_page.messages.updated'
      submitFn: Records.users.updateProfile
      successCallback: @init

  @init()
  $scope.$on 'updateProfile', => @init()

  @setLocale = ->
    $translate.use(@user.locale)
    lc_locale = @user.locale.toLowerCase().replace('_','-')
    return if lc_locale == "en"
    fetch("#{AppConfig.assetRoot}/moment_locales/#{lc_locale}.js").then((resp) -> resp.text()).then (data) ->
      eval(data)
      moment.locale(lc_locale)

  @availableLocales = ->
    AppConfig.locales

  @changePicture = ->
    ModalService.open ChangePictureForm

  @changePassword = ->
    ModalService.open ChangePasswordForm

  @deactivateUser = ->
    ModalService.open DeactivationModal

  return
