Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

angular.module('loomioApp').directive 'translateButton', (LoadingService) ->
  scope: {model: '=', showdot: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/translate_button/translate_button.html'
  replace: true
  controller: ($scope) ->
    $scope.canTranslate = ->
      AbilityService.canTranslate($scope.model) and !$scope.translateExecuting and !$scope.translated

    $scope.translate = ->
      Records.translations.fetchTranslation($scope.model, Session.user().locale).then (data) ->
        $scope.translated = true
        $scope.$emit 'translationComplete', data.translations[0].fields
    LoadingService.applyLoadingFunction $scope, 'translate'
