TimeService = require 'shared/services/time_service.coffee'

angular.module('loomioApp').directive 'pollMeetingTime', ->
  scope: {name: '=', zone: '='}
  template: "<span>{{displayDate(name, zone)}}</span>"
  controller: ($scope) ->
    $scope.displayDate = TimeService.displayDate
