Records  = require 'shared/services/records.coffee'
EventBus = require 'shared/services/event_bus.coffee'

angular.module('loomioApp').directive 'announcementChip', ->
  scope: {user: '=', showClose: '=?'}
  replace: true
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
  controller: ['$scope', ($scope) ->
    $scope.removeRecipient = ->
      EventBus.emit $scope, 'removeRecipient', $scope.user
  ]
