angular.module('loomioApp').factory 'TranslationService', (Session, Records) ->
  new class TranslationService

    listenForTranslations: (scope) ->
      scope.$on 'translationComplete', (e, translatedFields) =>
        return if e.defaultPrevented
        e.preventDefault()
        scope.translation = translatedFields

    inline: (scope, model) ->
      Records.translations.fetchTranslation(model, Session.user().locale).then (data) ->
        scope.translated = true
        scope.$emit 'translationComplete', data.translations[0].fields
