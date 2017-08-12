angular.module('loomioApp').directive 'threadItem', ($translate, PollService) ->
  scope: {event: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/thread_item.html'
  controller: ($scope) ->
    $scope.pollType = ->
      if $scope.event.isPollEvent()
        $translate.instant("poll_types.#{$scope.event.model().poll().pollType}").toLowerCase()
