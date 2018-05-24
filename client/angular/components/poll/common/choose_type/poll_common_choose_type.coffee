AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

{ iconFor } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonChooseType', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/choose_type/poll_common_choose_type.html'
  controller: ['$scope', ($scope) ->

    $scope.choose = (type) ->
      EventBus.emit $scope, 'nextStep', type

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.iconFor = (pollType) ->
      iconFor { pollType: pollType } # :/
  ]
