{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonOutcomeForm', ->
  scope: {outcome: '='}
  template: require('./poll_common_outcome_form.haml')
  controller: ['$scope', ($scope) ->
    $scope.datesAsOptions = ->
      fieldFromTemplate $scope.outcome.poll().pollType, 'dates_as_options'
  ]
