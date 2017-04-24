angular.module('loomioApp').directive 'pollCommonStanceChoice', (PollService) ->
  scope: {stanceChoice: '='}
  templateUrl: 'generated/components/poll/common/stance_choice/poll_common_stance_choice.html'
  controller: ($scope) ->
    $scope.translateOptionName = ->
      return unless $scope.stanceChoice.poll()
      PollService.fieldFromTemplate($scope.stanceChoice.poll().pollType, 'translate_option_name')

    $scope.hasVariableScore = ->
      return unless $scope.stanceChoice.poll()
      PollService.fieldFromTemplate($scope.stanceChoice.poll().pollType, 'has_variable_score')

    $scope.datesAsOptions = ->
      return unless $scope.stanceChoice.poll()
      PollService.fieldFromTemplate($scope.stanceChoice.poll().pollType, 'dates_as_options')
