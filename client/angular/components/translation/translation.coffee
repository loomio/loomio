angular.module('loomioApp').directive 'translation', ->
  scope: {model: '=', field: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/translation/translation.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.translated = $scope.model.translation[$scope.field]
  ]
