angular.module('loomioApp').factory 'TranslationService', ($translate) ->
  new class TranslationService

    # set the 'translations' value on scope to a hash with translated values
    eagerTranslate: (scope, translations) ->
      keys = _.keys(translations)
      values = _.map _.toArray(translations), (translateKey) ->
        $translate.instant(translateKey)
      scope.translations = _.object keys, values

    listenForTranslations: (scope, context) ->
      context = context or scope
      scope.$on 'translationComplete', (e, translatedFields) =>
        return if e.defaultPrevented
        e.preventDefault()
        context.translation = translatedFields
