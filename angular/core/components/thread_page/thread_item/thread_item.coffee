angular.module('loomioApp').directive 'threadItem', ($compile, $translate, LmoUrlService, EventHeadlineService) ->
  scope: {event: '=', page: '=', root: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'

  link: (scope, element, attrs) ->
    if scope.root
      $compile("<event-children parent=\"event\" page=\"page\"></event-children>")(scope, (cloned, scope) -> element.append(cloned))

  controller: ($scope) ->
    $scope.headline = ->
      EventHeadlineService.headlineFor($scope.event)

    $scope.link = ->
      LmoUrlService.discussion $scope.event.discussion(), from: $scope.event.sequenceId

    if $scope.root
      $scope.$on 'replyToCommentClicked', (e, parentComment) ->
        $scope.$broadcast 'showReplyForm', parentComment
