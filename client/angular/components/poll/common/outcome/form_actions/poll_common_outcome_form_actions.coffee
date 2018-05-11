{ submitOutcome } = require 'shared/helpers/form'
{ submitOnEnter } = require 'shared/helpers/keyboard'

angular.module('loomioApp').directive 'pollCommonOutcomeFormActions', ->
  scope: {outcome: '='}
  replace: true
  templateUrl: 'generated/components/poll/common/outcome/form_actions/poll_common_outcome_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitOutcome $scope, $scope.outcome
    submitOnEnter($scope)
  ]
