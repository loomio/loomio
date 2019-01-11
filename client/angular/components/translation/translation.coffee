angular.module('loomioApp').directive 'translation', ->
  scope: {model: '=', field: '@'}
  restrict: 'E'
  template: require('./translation.haml')
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.translated = $scope.model.translation[$scope.field]
  ]
