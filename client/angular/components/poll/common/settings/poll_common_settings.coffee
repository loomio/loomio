{ settingsFor } = require 'shared/helpers/poll'

angular.module('loomioApp').directive 'pollCommonSettings', ->
  scope: {poll: '='}
  template: require('./poll_common_settings.haml')
  controller: ['$scope', ($scope) ->
    $scope.settings = settingsFor $scope.poll

    $scope.$watch 'poll.anonymous', -> $scope.settings = settingsFor $scope.poll

    $scope.snakify = (setting) ->
      _.snakeCase setting
  ]
