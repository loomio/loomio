angular.module('loomioApp').directive 'threadItem', ($compile, $translate, LmoUrlService, EventHeadlineService) ->
  scope: {event: '=', eventWindow: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'

  link: (scope, element, attrs) ->
    if scope.event.depth == 1 and scope.eventWindow.useNesting
      $compile("<event-children discussion=\"eventWindow.discussion\" parent_event=\"event\" settings=\"eventWindow.settings\"></event-children>")(scope, (cloned, scope) -> element.append(cloned))

  controller: ($scope) ->
    $scope.isUnread = ->
      $scope.eventWindow.isUnread($scope.event)

    $scope.headline = ->
      EventHeadlineService.headlineFor($scope.event)

    $scope.link = ->
      LmoUrlService.discussion $scope.eventWindow.discussion, from: $scope.event.sequenceId

    if $scope.root
      $scope.$on 'replyToCommentClicked', (e, parentComment) ->
        $scope.$broadcast 'showReplyForm', parentComment
