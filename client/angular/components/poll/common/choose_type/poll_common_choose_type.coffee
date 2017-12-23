AppConfig = require 'shared/services/app_config.coffee'

angular.module('loomioApp').directive 'pollCommonChooseType', (PollService) ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/choose_type/poll_common_choose_type.html'
  controller: ($scope) ->

    $scope.choose = (type) ->
      $scope.$emit 'nextStep', type

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.iconFor = (pollType) ->
      PollService.fieldFromTemplate(pollType, 'material_icon')
