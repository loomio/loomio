angular.module('loomioApp').directive 'timeZoneSelect', (AppConfig) ->
  scope: {zone: '='}
  restrict: 'E'
  templateUrl: 'generated/components/time_zone_select/time_zone_select.html'
  replace: true
  controller: ($scope) ->
    $scope.zones = AppConfig.timeZones
    $scope.zone  = $scope.zone or _.find _.pluck($scope.zones, 'value'), (zone) ->
      AppConfig.timeZone.match(///#{zone}///i)

    $scope.change = ->
      $scope.$emit 'timeZoneSelected', $scope.zone
