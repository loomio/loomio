angular.module('loomioApp').directive 'membershipRequestsCard', ->
  scope: {group: '='}
  restrict: 'E'
  templateUrl: 'generated/components/group_page/membership_requests_card/membership_requests_card.html'
  replace: true
  controller: ($scope, Records, AbilityService) ->
    $scope.loaded = false
    Records.membershipRequests.fetchPendingByGroup($scope.group.key).then ->
      $scope.loaded = true

    $scope.canManageMembershipRequests = ->
      AbilityService.canManageMembershipRequests($scope.group)
