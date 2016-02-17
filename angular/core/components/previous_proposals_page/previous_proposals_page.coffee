angular.module('loomioApp').controller 'PreviousProposalsPageController', ($scope, $rootScope, $routeParams, Records, AbilityService) ->
  $rootScope.$broadcast('currentComponent', { page: 'previousProposalsPage'})

  init = =>
    Records.groups.findOrFetchById($routeParams.key).then (group) =>
      @group = group
      Records.proposals.fetchClosedByGroup($routeParams.key).then =>
        Records.votes.fetchMyVotes(@group)

  $scope.$on 'currentUserMembershipsLoaded', init
  init()

  return
