AppConfig   = require 'shared/services/app_config.coffee'
TimeService = require 'shared/services/time_service.coffee'

angular.module('loomioApp').directive 'timeZoneSelect', ($translate) ->
  scope: {zone: '='}
  restrict: 'E'
  templateUrl: 'generated/components/time_zone_select/time_zone_select.html'
  replace: true
  controller: ($scope) ->
    $scope.q = ""
    $scope.isOpen = false
    $scope.zone = $scope.zone || AppConfig.timeZone
    $scope.currentZone = ->
      TimeService.nameForZone($scope.zone, $translate.instant('common.local_time'))

    $scope.zoneFromName = (name) ->
      AppConfig.timeZones[name]

    $scope.offsetFromName = (name) ->
      moment().tz(zoneFromName(name)).format('Z')

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
        $scope.$emit 'timeZoneSelected', AppConfig.timeZones[$scope.q]
        $scope.close()
