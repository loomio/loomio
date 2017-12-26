Session = require 'shared/services/session.coffee'

angular.module('loomioApp').directive 'pollCommonPreview', ->
  scope: {poll: '=', displayGroupName: '=?'}
  templateUrl: 'generated/components/poll/common/preview/poll_common_preview.html'
  controller: ($scope) ->

    $scope.showGroupName = ->
      $scope.displayGroupName && $scope.poll.group()
