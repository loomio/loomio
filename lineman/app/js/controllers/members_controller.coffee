angular.module('loomioApp').controller 'MembersController', ($scope, MembershipService) ->
  MembershipService.fetchByGroup $scope.group.id
