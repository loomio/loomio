angular.module('loomioApp').directive 'translateButton', ->
  scope: {model: '=', showdot: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/translate_button/translate_button.html'
  replace: true
  controller: ($scope, Records, AbilityService, Session, LoadingService) ->
    $scope.canTranslate = ->
      AbilityService.canTranslate($scope.model) and !$scope.translateExecuting and !$scope.translated

    $scope.translate = ->
      Records.translations.fetchTranslation($scope.model, Session.user().locale).then (data) ->
        $scope.translated = true
        $scope.$emit 'translationComplete', data.translations[0].fields
    LoadingService.applyLoadingFunction $scope, 'translate'
