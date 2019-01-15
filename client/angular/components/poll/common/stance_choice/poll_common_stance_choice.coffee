{ fieldFromTemplate } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonStanceChoice', ->
  scope: {stanceChoice: '='}
  template: require('./poll_common_stance_choice.haml')
  controller: ['$scope', ($scope) ->
    $scope.translateOptionName = ->
      return unless $scope.stanceChoice.poll()
      fieldFromTemplate($scope.stanceChoice.poll().pollType, 'translate_option_name')

    $scope.hasVariableScore = ->
      return unless $scope.stanceChoice.poll()
      fieldFromTemplate($scope.stanceChoice.poll().pollType, 'has_variable_score')

    $scope.datesAsOptions = ->
      return unless $scope.stanceChoice.poll()
      fieldFromTemplate($scope.stanceChoice.poll().pollType, 'dates_as_options')
  ]
