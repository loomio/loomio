angular.module('loomioApp').factory 'BootService', ($location, Records, IntercomService, MessageChannelService, ModalService, GroupForm, AngularWelcomeModal) ->
  new class BootService

    boot: ->
      IntercomService.boot()
      MessageChannelService.subscribe()
      if $location.search().start_group?
        ModalService.open GroupForm, group: -> Records.groups.build()
      if $location.search().welcome?
        ModalService.open AngularWelcomeModal
