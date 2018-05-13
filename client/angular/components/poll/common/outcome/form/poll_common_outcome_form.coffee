{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonOutcomeForm', ->
  scope: {outcome: '='}
  templateUrl: 'generated/components/poll/common/outcome/form/poll_common_outcome_form.html'
  controller: ['$scope', ($scope) ->
    $scope.datesAsOptions = ->
      fieldFromTemplate $scope.outcome.poll().pollType, 'dates_as_options'
  ]
