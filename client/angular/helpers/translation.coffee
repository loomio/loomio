Records = require 'shared/services/records.coffee'
Session = require 'shared/services/session.coffee'

module.exports =
  listenForTranslations: ($scope) ->
    $scope.$on 'translationComplete', (e, translatedFields) =>
      return if e.defaultPrevented
      e.preventDefault()
      $scope.translation = translatedFields

  performTranslation: ($scope, model) ->
    Records.translations.fetchTranslation(model, Session.user().locale).then (data) ->
      $scope.translated = true
      $scope.$emit 'translationComplete', data.translations[0].fields
