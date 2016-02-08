angular.module('loomioApp').directive 'translation', ->
  scope: {translation: '=', field: '@'}
  restrict: 'E'
  templateUrl: 'generated/components/translation/translation.html'
  replace: true
  controller: ($scope) ->
    $scope.translated = $scope.translation[$scope.field]
