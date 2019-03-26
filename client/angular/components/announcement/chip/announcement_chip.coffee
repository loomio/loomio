Records  = require 'shared/services/records'
EventBus = require 'shared/services/event_bus'

angular.module('loomioApp').directive 'announcementChip', ->
  scope: {user: '=', showClose: '=?'}
  replace: true
  restrict: 'E'
  templateUrl: 'generated/components/announcement/chip/announcement_chip.html'
  controller: ['$scope', ($scope) ->
    $scope.removeRecipient = ->
      EventBus.emit $scope, 'removeRecipient', $scope.user
  ]
