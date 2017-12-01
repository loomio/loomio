angular.module('loomioApp').directive 'pollCommonChooseType', (PollService, AppConfig) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/choose_type/poll_common_choose_type.html'
  controller: ($scope) ->

    $scope.choose = (type) ->
      $scope.$emit 'nextStep', type

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.iconFor = (pollType) ->
      PollService.fieldFromTemplate(pollType, 'material_icon')
