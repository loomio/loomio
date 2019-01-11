{ submitOutcome } = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'pollCommonOutcomeFormActions', ->
  scope: {outcome: '='}
  replace: true
  template: require('./poll_common_outcome_form_actions.haml')
  controller: ['$scope', ($scope) ->
    $scope.submit = submitOutcome $scope, $scope.outcome
    submitOnEnter($scope)
  ]
