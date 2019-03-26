{ submitMembership } = require 'shared/helpers/form'
{ submitOnEnter }    = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'membershipFormActions', ->
  scope: {membership: '='}
  replace: true
  templateUrl: 'generated/components/membership/form_actions/membership_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitMembership $scope, $scope.membership
    submitOnEnter $scope
  ]
