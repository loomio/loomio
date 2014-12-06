angular.module('loomioApp').controller 'NotificationItemController', ($scope) ->
  $scope.event = $scope.notification.event()
  $scope.actor = $scope.notification.event().actor()
