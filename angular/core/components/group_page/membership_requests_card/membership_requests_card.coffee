angular.module('loomioApp').directive 'membershipRequestsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/membership_requests_card/membership_requests_card.html'
  replace: true
  controller: ($scope, Records, AbilityService) ->
    $scope.canManageMembershipRequests = ->
      AbilityService.canManageMembershipRequests($scope.group)

    if $scope.canManageMembershipRequests()
      Records.membershipRequests.fetchPendingByGroup($scope.group.key)
