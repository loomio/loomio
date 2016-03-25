angular.module('loomioApp').factory 'BootService', ($location, Records, IntercomService, MessageChannelService, AbilityService, ModalService, GroupForm) ->
  new class BootService

    boot: ->
      if $location.search().start_group?
        ModalService.open GroupForm, group: -> Records.groups.build()
      if AbilityService.isLoggedIn()
        IntercomService.boot()
        MessageChannelService.subscribe()
