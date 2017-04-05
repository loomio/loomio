angular.module('loomioApp').directive 'timeZoneSelect', (AppConfig) ->
  restrict: 'E'
  templateUrl: 'generated/components/time_zone_select/time_zone_select.html'
  replace: true
  controller: ($scope) ->
    $scope.timeZones = AppConfig.timeZones
    $scope.timeZone  = _.find _.pluck($scope.timeZones, 'value'), (zone) ->
      AppConfig.timeZone.match(///#{zone}///i)

    $scope.change = ->
      $scope.$emit 'timeZoneSelected', $scope.timeZone
