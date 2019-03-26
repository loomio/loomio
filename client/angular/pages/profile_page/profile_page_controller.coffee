AppConfig      = require 'shared/services/app_config'
Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
ModalService   = require 'shared/services/modal_service'
LmoUrlService  = require 'shared/services/lmo_url_service'

{ submitForm }   = require 'shared/helpers/form'
{ hardReload }   = require 'shared/helpers/window'

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
    ModalService.open 'ConfirmModal', confirm: ->
      text:
        title: 'deactivate_user_form.title'
        submit: 'deactivation_modal.submit'
        fragment: 'deactivate_user'
      submit: -> ModalService.open 'ConfirmModal', confirm: confirm

  @deleteUser = ->
    ModalService.open 'ConfirmModal', confirm: ->
      text:
        title: 'delete_user_modal.title'
        submit: 'delete_user_modal.submit'
        fragment: 'delete_user_modal'
      submit: -> Records.users.destroy()
      successCallback: hardReload

  confirm = ->
    scope: {user: Session.user()}
    submit: -> Records.users.deactivate(Session.user())
    text:
      title:    'deactivate_user_form.title'
      submit:   'deactivate_user_form.submit'
      fragment: 'deactivate_user_confirmation'
    successCallback: hardReload

  return

$controller.$inject = ['$scope', '$rootScope']
angular.module('loomioApp').controller 'ProfilePageController', $controller
