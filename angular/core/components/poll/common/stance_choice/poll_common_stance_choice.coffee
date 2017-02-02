angular.module('loomioApp').directive 'pollCommonStanceChoice', (PollService) ->
  scope: {stanceChoice: '='}
  templateUrl: 'generated/components/poll/common/stance_choice/poll_common_stance_choice.html'
  controller: ($scope) ->
    $scope.translateOptionName = PollService.fieldFromTemplate($scope.stanceChoice.poll().pollType, 'translate_option_name')
