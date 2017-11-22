angular.module('loomioApp').directive 'threadItem', ($compile, $timeout, $translate, LmoUrlService, EventHeadlineService, Session) ->
  scope: {event: '=', eventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'

  link: (scope, element, attrs) ->
    if scope.event.depth == 1 && scope.eventWindow.useNesting
      $compile("<event-children discussion=\"eventWindow.discussion\" parent_event=\"event\" parent_event_window=\"eventWindow\"></event-children><add-comment-panel parent_event=\"event\" event_window=\"eventWindow\"></add-comment-panel>")(scope, (cloned, scope) -> element.append(cloned))

  controller: ($scope) ->
    if $scope.event.depth == 1 && $scope.eventWindow.useNesting
      $scope.$on 'replyButtonClicked', (e, parentEvent, comment) ->
        if $scope.event.id == parentEvent.id
          $scope.eventWindow.max = false
          $scope.$broadcast 'showReplyForm', comment

    $scope.mdColors = ->
      obj = {'border-color': 'primary-500'}
      obj['background-color'] = 'accent-50' if $scope.isFocused
      obj

    $scope.isFocused = $scope.eventWindow.discussion.requestedSequenceId == $scope.event.sequenceId

    $scope.indent = ->
      $scope.event.depth == 2 && $scope.eventWindow.useNesting

    $scope.isUnread = ->
      (Session.user().id != $scope.event.actorId) && $scope.eventWindow.isUnread($scope.event)

    $scope.headline = ->
      EventHeadlineService.headlineFor($scope.event, $scope.eventWindow.useNesting)

    $scope.link = ->
      LmoUrlService.discussion $scope.eventWindow.discussion, from: $scope.event.sequenceId
