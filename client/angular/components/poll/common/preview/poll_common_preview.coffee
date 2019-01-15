Session = require 'shared/services/session'

angular.module('loomioApp').directive 'pollCommonPreview', ->
  scope: {poll: '=', displayGroupName: '=?'}
  template: require('./poll_common_preview.haml')
  controller: ['$scope', ($scope) ->

    $scope.showGroupName = ->
      $scope.displayGroupName && $scope.poll.group()
  ]
