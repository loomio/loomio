AppConfig   = require 'shared/services/app_config.coffee'
EventBus    = require 'shared/services/event_bus.coffee'
TimeService = require 'shared/services/time_service.coffee'
I18n        = require 'shared/services/i18n.coffee'

angular.module('loomioApp').directive 'timeZoneSelect', ->
  scope: {zone: '='}
  restrict: 'E'
  templateUrl: 'generated/components/time_zone_select/time_zone_select.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.q = ""
    $scope.isOpen = false
    $scope.zone = $scope.zone || AppConfig.timeZone
    $scope.currentZone = ->
      TimeService.nameForZone($scope.zone, I18n.t('common.local_time'))

    $scope.zoneFromName = (name) ->
      AppConfig.timeZones[name]

    $scope.open = ->
      $scope.q = ""
      $scope.isOpen = true

    $scope.close = ->
      $scope.isOpen = false

    $scope.names = ->
      _.filter _.keys(AppConfig.timeZones), (name) ->
        name.toLowerCase().includes($scope.q.toLowerCase())

    $scope.change = ->
      if AppConfig.timeZones[$scope.q]
        $scope.zone = AppConfig.timeZones[$scope.q]
        EventBus.emit $scope, 'timeZoneSelected', AppConfig.timeZones[$scope.q]
        $scope.close()
  ]
