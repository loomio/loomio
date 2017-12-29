AppConfig = require 'shared/services/app_config.coffee'

{ iconFor } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonChooseType', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/choose_type/poll_common_choose_type.html'
  controller: ['$scope', ($scope) ->

    $scope.choose = (type) ->
      $scope.$emit 'nextStep', type

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.iconFor = (pollType) ->
      iconFor { pollType: pollType } # :/
  ]
