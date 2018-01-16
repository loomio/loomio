{ submitOnEnter } = require 'shared/helpers/keyboard.coffee'
{ submitForm }    = require 'shared/helpers/form.coffee'

angular.module('loomioApp').directive 'pollCommonOutcomeFormActions', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome_form_actions/poll_common_outcome_form_actions.html'
  controller: ['$scope', ($scope) ->
    $scope.submit = submitOutcome $scope, $scope.outcome
    submitOnEnter($scope)
  ]
