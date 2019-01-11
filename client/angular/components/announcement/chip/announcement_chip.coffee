Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'announcementChip', ->
  scope: {user: '=', showClose: '=?'}
  replace: true
  restrict: 'E'
  template: require('./announcement_chip.haml')
  controller: ['$scope', ($scope) ->
    $scope.removeRecipient = ->
      EventBus.emit $scope, 'removeRecipient', $scope.user
  ]
