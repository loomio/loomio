angular.module('loomioApp').controller 'GroupController', ($scope, group, eventSubscription, EventService) ->
  $scope.group = group

  EventService.subscribeTo(eventSubscription)
