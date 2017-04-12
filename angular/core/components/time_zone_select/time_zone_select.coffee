angular.module('loomioApp').directive 'timeZoneSelect', ($translate, AppConfig) ->
  scope: {zone: '='}
  restrict: 'E'
  templateUrl: 'generated/components/time_zone_select/time_zone_select.html'
  replace: true
  controller: ($scope) ->
    $scope.zones = [
      name: $translate.instant("timezones.local", value: AppConfig.timeZone)
      value: AppConfig.timeZone
    ].concat AppConfig.timeZones
    $scope.zone = $scope.zone or AppConfig.timeZone

    $scope.change = ->
      $scope.$emit 'timeZoneSelected', $scope.zone
    $scope.change()
