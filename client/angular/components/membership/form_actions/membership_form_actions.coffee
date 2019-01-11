{ submitMembership } = require 'shared/helpers/form'
{ submitOnEnter }    = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'membershipFormActions', ->
  scope: {membership: '='}
  replace: true
  template: require('./membership_form_actions.haml')
  controller: ['$scope', ($scope) ->
    $scope.submit = submitMembership $scope, $scope.membership
    submitOnEnter $scope
  ]
