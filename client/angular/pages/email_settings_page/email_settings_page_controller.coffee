Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

{ submitForm }   = require 'shared/helpers/form.coffee'

$controller = ($rootScope) ->
  EventBus.broadcast $rootScope, 'currentComponent', { titleKey: 'email_settings_page.header', page: 'emailSettingsPage'}

  @init = =>
    return unless AbilityService.isLoggedIn() or Session.user().restricted?
    @user = Session.user().clone()
  @init()

  @groupVolume = (group) ->
    group.membershipFor(Session.user()).volume

  @defaultSettingsDescription = ->
    "email_settings_page.default_settings.#{Session.user().defaultMembershipVolume}_description"

  @changeDefaultMembershipVolume = ->
    ModalService.open 'ChangeVolumeForm', model: => Session.user()

  @editSpecificGroupVolume = (group) ->
    ModalService.open 'ChangeVolumeForm', model: => group.membershipFor(Session.user())

  @submit = submitForm @, @user,
    submitFn: Records.users.updateProfile
    flashSuccess: 'email_settings_page.messages.updated'
    successCallback: -> LmoUrlService.goTo '/dashboard' if AbilityService.isLoggedIn()

  return

$controller.$inject = ['$rootScope']
angular.module('loomioApp').controller 'EmailSettingsPageController', $controller
