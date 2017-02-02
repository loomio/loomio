angular.module('loomioApp').directive 'pollCommonStanceIcon', (PollService) ->
  scope: {stanceChoice: '='}
  templateUrl: 'generated/components/poll/common/stance_icon/poll_common_stance_icon.html'
  controller: ($scope) ->
    $scope.useOptionIcon = PollService.fieldFromTemplate($scope.stanceChoice.poll().pollType, 'has_option_icons')
