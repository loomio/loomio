angular.module('loomioApp').directive 'threadItem', ($translate, EventHeadlineService) ->
  scope: {event: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'
  controller: ($scope) ->
    $scope.headline = ->
      EventHeadlineService.headlineFor($scope.event)
