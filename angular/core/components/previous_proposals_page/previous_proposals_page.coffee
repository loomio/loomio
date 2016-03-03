angular.module('loomioApp').controller 'PreviousProposalsPageController', ($scope, $rootScope, $routeParams, Records, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'previousProposalsPage'})
  Records.groups.findOrFetchById($routeParams.key).then (group) => @group = group
  Records.proposals.fetchClosedByGroup($routeParams.key)

  return
