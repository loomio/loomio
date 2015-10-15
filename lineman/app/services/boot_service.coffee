angular.module('loomioApp').factory 'BootService', ($location, Records, IntercomService, MessageChannelService, ModalService, StartGroupForm) ->
  new class BootService

    boot: ->
      IntercomService.boot()
      MessageChannelService.subscribeToUser()
      if $location.search().start_group?
        ModalService.open StartGroupForm, group: -> Records.groups.build()
