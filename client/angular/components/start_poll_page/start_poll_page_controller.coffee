Records      = require 'shared/services/records.coffee'
ModalService = require 'shared/services/modal_service.coffee'

{ listenForLoading } = require 'angular/helpers/loading.coffee'

angular.module('loomioApp').controller 'StartPollPageController', ($scope, $location, $rootScope, $routeParams, PollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build
    title:       $location.search().title
    pollType:    $routeParams.poll_type
    groupId:     $location.search().group_id
    customFields:
      pending_emails: _.compact(($location.search().pending_emails || "").split(','))

  @icon = ->
    PollService.iconFor(@poll)

  PollService.applyPollStartSequence @,
    emitter: $scope
    afterSaveComplete: (poll) ->
      ModalService.open 'PollCommonShareModal', poll: -> poll

  listenForLoading $scope

  return
