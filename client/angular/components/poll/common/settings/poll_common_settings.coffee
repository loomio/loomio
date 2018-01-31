{ settingsFor } = require 'shared/helpers/poll.coffee'

angular.module('loomioApp').directive 'pollCommonSettings', ->
  scope: {poll: '='}
  templateUrl: 'generated/components/poll/common/settings/poll_common_settings.html'
  controller: ['$scope', ($scope) ->
    $scope.settings = settingsFor $scope.poll

    $scope.snakify = (setting) ->
      _.snakeCase setting
  ]
