Records       = require 'shared/services/records.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ listenForLoading }       = require 'angular/helpers/listen.coffee'
{ iconFor }                = require 'shared/helpers/poll.coffee'
{ applyPollStartSequence } = require 'angular/helpers/apply.coffee'

angular.module('loomioApp').controller 'StartPollPageController', ($scope, $rootScope, $routeParams) ->
  $rootScope.$broadcast('currentComponent', { page: 'startPollPage', skipScroll: true })
  @poll = Records.polls.build
    title:       LmoUrlService.params().title
    pollType:    $routeParams.poll_type
    groupId:     LmoUrlService.params().group_id
    customFields:
      pending_emails: _.compact((LmoUrlService.params().pending_emails || "").split(','))

  @icon = ->
    iconFor(@poll)

  applyPollStartSequence(@,
    emitter: $scope
    afterSaveComplete: (poll) ->
      ModalService.open 'PollCommonShareModal', poll: -> poll)

  listenForLoading $scope

  return
