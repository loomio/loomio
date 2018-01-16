Records       = require 'shared/services/records.coffee'
EventBus      = require 'shared/services/event_bus.coffee'
ModalService  = require 'shared/services/modal_service.coffee'
LmoUrlService = require 'shared/services/lmo_url_service.coffee'

{ listenForLoading }       = require 'shared/helpers/listen.coffee'
{ iconFor }                = require 'shared/helpers/poll.coffee'
{ applyPollStartSequence } = require 'shared/helpers/apply.coffee'

$controller = ($scope, $rootScope, $routeParams) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'startPollPage', skipScroll: true }
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
      ModalService.open 'AnnouncementModal', announcement: ->
        Records.announcements.buildFromMOdal(poll, 'poll_created')
  )

  listenForLoading $scope

  return

$controller.$inject = ['$scope', '$rootScope', '$routeParams']
angular.module('loomioApp').controller 'StartPollPageController', $controller
