Session        = require 'shared/services/session'
Records        = require 'shared/services/records'
EventBus       = require 'shared/services/event_bus'
AbilityService = require 'shared/services/ability_service'
LmoUrlService  = require 'shared/services/lmo_url_service'
I18n           = require 'shared/services/i18n'

{ submitForm } = require 'shared/helpers/form'
{ eventHeadline, eventTitle, eventPollType } = require 'shared/helpers/helptext'

angular.module('loomioApp').directive 'threadItem', ['$compile', ($compile) ->
  scope: {event: '=', eventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'

  link: (scope, element, attrs) ->
    if scope.event.isSurface() && scope.eventWindow.useNesting
      $compile("<event-children discussion=\"eventWindow.discussion\" parent_event=\"event\" parent_event_window=\"eventWindow\"></event-children><add-comment-panel parent_event=\"event\" event_window=\"eventWindow\"></add-comment-panel>")(scope, (cloned, scope) -> element.append(cloned))

  controller: ['$scope', ($scope) ->
    $scope.debug = -> window.Loomio.debug
    if $scope.event.isSurface() && $scope.eventWindow.useNesting
      EventBus.listen $scope, 'replyButtonClicked', (e, parentEvent, comment) ->
        if $scope.event.id == parentEvent.id
          $scope.eventWindow.max = false
          EventBus.broadcast $scope, 'showReplyForm', comment

    $scope.canRemoveEvent = -> AbilityService.canRemoveEventFromThread($scope.event)
    $scope.removeEvent = submitForm $scope, $scope.event,
      submitFn: $scope.event.removeFromThread
      flashSuccess: 'thread_item.event_removed'

    $scope.mdColors = ->
      obj = {'border-color': 'primary-500'}
      obj['background-color'] = 'accent-50' if $scope.isFocused
      obj

    $scope.isFocused = $scope.eventWindow.discussion.requestedSequenceId == $scope.event.sequenceId

    $scope.indent = ->
      $scope.event.isNested() && $scope.eventWindow.useNesting

    $scope.isUnread = ->
      (Session.user().id != $scope.event.actorId) && $scope.eventWindow.isUnread($scope.event)

    $scope.headline = ->
      I18n.t eventHeadline($scope.event, $scope.eventWindow.useNesting),
        author:   $scope.event.actorName() || I18n.t('common.anonymous')
        username: $scope.event.actorUsername()
        key:      $scope.event.model().key
        title:    eventTitle($scope.event)
        polltype: I18n.t(eventPollType($scope.event)).toLowerCase()

    $scope.link = ->
      LmoUrlService.event $scope.event
  ]
]
