angular.module('loomioApp').directive 'loading', ->
  scope: {diameter: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/loading/loading.html'
  replace: true
  controller: ($scope) ->
    $scope.diameter = $scope.diameter or 30
