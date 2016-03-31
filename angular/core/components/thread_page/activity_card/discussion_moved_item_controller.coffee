angular.module('loomioApp').controller 'DiscussionMovedItemController', ($scope) ->
  $scope.groupName = $scope.event.group().name
