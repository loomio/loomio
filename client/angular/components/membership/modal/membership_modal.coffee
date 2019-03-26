angular.module('loomioApp').factory 'MembershipModal', ->
  templateUrl: 'generated/components/membership/modal/membership_modal.html'
  controller: ['$scope', 'membership', ($scope, membership) ->
    $scope.membership = membership.clone()
  ]
