AppConfig      = require 'shared/services/app_config.coffee'
Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'

{ submitForm }   = require 'shared/helpers/form.coffee'

$controller = ($scope, $rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { titleKey: 'profile_page.profile', page: 'profilePage'}

  @showHelpTranslate = ->
    AppConfig.features.app.help_link

  @init = =>
    return unless AbilityService.isLoggedIn()
    @user = Session.user().clone()
    Session.updateLocale(@user.locale)
    @submit = submitForm @, @user,
      flashSuccess: 'profile_page.messages.updated'
      submitFn: Records.users.updateProfile
      successCallback: @init

  @init()
  EventBus.listen $scope, 'updateProfile', => @init()

  @availableLocales = ->
    AppConfig.locales

  @changePicture = ->
    ModalService.open 'ChangePictureForm'

  @changePassword = ->
    ModalService.open 'ChangePasswordForm'

  @deactivateUser = ->
    ModalService.open 'DeactivationModal'

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'ProfilePageController', $controller
