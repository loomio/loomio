angular.module('loomioApp').directive 'timeZoneSelect', ($translate, AppConfig, TimeService) ->
  scope: {zone: '='}
  restrict: 'E'
  templateUrl: 'generated/components/time_zone_select/time_zone_select.html'
  replace: true
  controller: ($scope) ->
    $scope.q = ""
    $scope.isOpen = false
    $scope.zone = $scope.zone || AppConfig.timeZone
    $scope.name = TimeService.nameForZone($scope.zone)

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
