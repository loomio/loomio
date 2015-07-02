angular.module('loomioApp').directive 'membershipRequestsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/membership_requests_card/membership_requests_card.html'
  replace: true
  controller: ($scope, Records, AbilityService) ->
    Records.membershipRequests.fetchPendingByGroup($scope.group.key)

    $scope.canManageMembers = ->
      true
      # AbilityService.canAddMembers($scope.group)
