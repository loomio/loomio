Records        = require 'shared/services/records'
AbilityService = require 'shared/services/ability_service'

angular.module('loomioApp').directive 'membershipRequestsCard', ->
  scope: {group: '='}
  restrict: 'E'
  template: require('./membership_requests_card.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.canManageMembershipRequests = ->
      AbilityService.canManageMembershipRequests($scope.group)

    if $scope.canManageMembershipRequests()
      Records.membershipRequests.fetchPendingByGroup($scope.group.key)
  ]
