angular.module('loomioApp').directive 'threadItem', ($compile, $translate, LmoUrlService, EventHeadlineService) ->
  scope: {event: '=', threadWindow: '=?', root: '=', useNesting: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'

  link: (scope, element, attrs) ->
    if scope.root and scope.useNesting
      $compile("<event-children parent=\"event\" thread-window=\"threadWindow\"></event-children>")(scope, (cloned, scope) -> element.append(cloned))

  controller: ($scope) ->
    $scope.isUnread = ->
      return false unless $scope.threadWindow?
      $scope.event.sequenceId > $scope.threadWindow.firstUnreadSequenceId

    $scope.headline = ->
      EventHeadlineService.headlineFor($scope.event)

    $scope.link = ->
      LmoUrlService.discussion $scope.event.discussion(), from: $scope.event.sequenceId

    if $scope.root
      $scope.$on 'replyToCommentClicked', (e, parentComment) ->
        $scope.$broadcast 'showReplyForm', parentComment
