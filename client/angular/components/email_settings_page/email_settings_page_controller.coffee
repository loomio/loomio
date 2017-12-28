Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
ModalService   = require 'shared/services/modal_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'

{ submitForm }   = require 'angular/helpers/form.coffee'
{ updateLocale } = require 'angular/helpers/user.coffee'

angular.module('loomioApp').controller 'EmailSettingsPageController', ($rootScope) ->
  $rootScope.$broadcast('currentComponent', { titleKey: 'email_settings_page.header', page: 'emailSettingsPage'})

  @init = =>
    return unless AbilityService.isLoggedIn() or Session.user().restricted?
    @user = Session.user().clone()
    updateLocale()
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
