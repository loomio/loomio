Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'
LmoUrlService  = require 'shared/services/lmo_url_service.coffee'
I18n           = require 'shared/services/i18n.coffee'

{ submitForm } = require 'angular/helpers/form.coffee'
{ eventHeadline, eventTitle, eventPollType } = require 'angular/helpers/helptext.coffee'

angular.module('loomioApp').directive 'threadItem', ($compile) ->
  scope: {event: '=', eventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'

  link: (scope, element, attrs) ->
    if scope.event.isSurface() && scope.eventWindow.useNesting
      $compile("<event-children discussion=\"eventWindow.discussion\" parent_event=\"event\" parent_event_window=\"eventWindow\"></event-children><add-comment-panel parent_event=\"event\" event_window=\"eventWindow\"></add-comment-panel>")(scope, (cloned, scope) -> element.append(cloned))

  controller: ($scope) ->
    $scope.debug = -> window.Loomio.debug
    if $scope.event.isSurface() && $scope.eventWindow.useNesting
      $scope.$on 'replyButtonClicked', (e, parentEvent, comment) ->
        if $scope.event.id == parentEvent.id
          $scope.eventWindow.max = false
          $scope.$broadcast 'showReplyForm', comment

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
        title:    eventTitle($scope.event)
        polltype: I18n.t(eventPollType($scope.event)).toLowerCase()

    $scope.link = ->
      LmoUrlService.discussion $scope.eventWindow.discussion, from: $scope.event.sequenceId
