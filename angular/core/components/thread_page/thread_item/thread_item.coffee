angular.module('loomioApp').directive 'threadItem', ($translate, LmoUrlService, EventHeadlineService) ->
  scope: {event: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'
  controller: ($scope) ->
    $scope.headline = ->
      EventHeadlineService.headlineFor($scope.event)

    $scope.link = ->
      LmoUrlService.discussion $scope.event.discussion(), from: $scope.event.sequenceId
