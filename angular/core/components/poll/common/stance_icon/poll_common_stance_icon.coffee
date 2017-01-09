angular.module('loomioApp').directive 'pollCommonStanceIcon', (PollService) ->
  scope: {stance: '='}
  templateUrl: 'generated/components/poll/common/stance_icon/poll_common_stance_icon.html'
  controller: ($scope) ->
    $scope.iconType = ->
      PollService.fieldFromTemplate($scope.stance.poll().pollType, 'option_icon_type')
