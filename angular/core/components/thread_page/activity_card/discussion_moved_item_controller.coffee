angular.module('loomioApp').controller 'DiscussionMovedItemController', ($scope, Records) ->
  $scope.group = Records.groups.find($scope.event.eventable.id)
