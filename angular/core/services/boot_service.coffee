angular.module('loomioApp').factory 'BootService', ($location, Records, IntercomService, MessageChannelService, AbilityService, ModalService, GroupForm, AppConfig, AngularWelcomeModal) ->
  new class BootService

    boot: ->
      if $location.search().start_group?
        ModalService.open GroupForm, group: -> Records.groups.build()
      if AppConfig.showWelcomeModal
        ModalService.open AngularWelcomeModal
      if AbilityService.isLoggedIn()
        IntercomService.boot()
        MessageChannelService.subscribe()
