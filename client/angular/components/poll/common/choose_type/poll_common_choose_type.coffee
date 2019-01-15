AppConfig = require 'shared/services/app_config'
EventBus  = require 'shared/services/event_bus'

{ iconFor } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonChooseType', ->
  scope: {poll: '='}
  template: require('./poll_common_choose_type.haml')
  controller: ['$scope', ($scope) ->

    $scope.choose = (type) ->
      EventBus.emit $scope, 'nextStep', type

    $scope.pollTypes = -> AppConfig.pollTypes

    $scope.iconFor = (pollType) ->
      iconFor { pollType: pollType } # :/
  ]
