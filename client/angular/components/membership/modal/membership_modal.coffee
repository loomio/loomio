angular.module('loomioApp').factory 'MembershipModal', ->
  template: require('./membership_modal.haml')
  controller: ['$scope', 'membership', ($scope, membership) ->
    $scope.membership = membership.clone()
  ]
