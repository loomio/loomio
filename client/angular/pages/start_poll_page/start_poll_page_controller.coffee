Records       = require 'shared/services/records'
EventBus      = require 'shared/services/event_bus'
ModalService  = require 'shared/services/modal_service'
LmoUrlService = require 'shared/services/lmo_url_service'

{ listenForLoading }       = require 'shared/helpers/listen'
{ iconFor }                = require 'shared/helpers/poll'
{ applyPollStartSequence } = require 'shared/helpers/apply'

$controller = ($scope, $rootScope, $routeParams) ->
  EventBus.broadcast $rootScope, 'currentComponent', { page: 'startPollPage', skipScroll: true }
  @poll = Records.polls.build
    title:       LmoUrlService.params().title
    pollType:    $routeParams.poll_type
    groupId:     parseInt(LmoUrlService.params().group_id)
    customFields:
      pending_emails: _.compact((LmoUrlService.params().pending_emails || "").split(','))

  @icon = ->
    iconFor(@poll)

  Records.groups.findOrFetch(LmoUrlService.params().group_id).then =>
    applyPollStartSequence @,
      emitter: $scope
      afterSaveComplete: (event) ->
        ModalService.open 'AnnouncementModal', announcement: ->
          Records.announcements.buildFromModel(event)

  listenForLoading $scope

  return

$controller.$inject = ['$scope', '$rootScope', '$routeParams']
angular.module('loomioApp').controller 'StartPollPageController', $controller
