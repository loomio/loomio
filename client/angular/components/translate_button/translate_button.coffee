Session        = require 'shared/services/session.coffee'
Records        = require 'shared/services/records.coffee'
EventBus       = require 'shared/services/event_bus.coffee'
AbilityService = require 'shared/services/ability_service.coffee'

{ applyLoadingFunction } = require 'shared/helpers/apply.coffee'

angular.module('loomioApp').directive 'translateButton', ->
  scope: {model: '=', showdot: '=?'}
  restrict: 'E'
  templateUrl: 'generated/components/translate_button/translate_button.html'
  replace: true
  controller: ['$scope', ($scope) ->
    $scope.canTranslate = ->
      AbilityService.canTranslate($scope.model) and !$scope.translateExecuting

    $scope.translate = ->
      Records.translations.fetchTranslation($scope.model, Session.user().locale).then (data) ->
        $scope.translated = true
        EventBus.emit $scope, 'translationComplete', data.translations[0].fields
    applyLoadingFunction($scope, 'translate')
  ]
