angular.module('loomioApp').factory 'TranslationService', ->
  new class TranslationService

    listenForTranslations: (scope, context) ->
      context = context or scope
      scope.$on 'translationComplete', (e, translatedFields) =>
        return if e.defaultPrevented
        e.preventDefault()
        context.translation = translatedFields
