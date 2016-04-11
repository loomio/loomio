angular.module('loomioApp').factory 'BootService', ($location, Records, AppConfig, IntercomService, MessageChannelService, User, AbilityService, ModalService, GroupForm) ->
  new class BootService

    boot: ->
      User.login AppConfig.seedRecords
      if $location.search().start_group?
        ModalService.open GroupForm, group: -> Records.groups.build()
      if AbilityService.isLoggedIn()
        IntercomService.boot()
        MessageChannelService.subscribe()
