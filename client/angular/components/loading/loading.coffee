angular.module('loomioApp').directive 'loading', ->
  scope: {diameter: '=?'}
  restrict: 'E'
  template: require('./loading.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.diameter = $scope.diameter or 30
  ]
