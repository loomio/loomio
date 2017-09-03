angular.module('loomioApp').directive 'stanceCreated', (ReactionService) ->
  scope: {eventable: '='}
  restrict: 'E'
  templateUrl: 'generated/components/thread_page/thread_item/stance_created.html'
  replace: true
  controller: ($scope) ->
    ReactionService.listenForReactions($scope, $scope.eventable)
