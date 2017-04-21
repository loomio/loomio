angular.module('loomioApp').factory 'TranslationService', ($translate) ->
  new class TranslationService

    # set the 'translations' value on scope to a hash with translated values
    eagerTranslate: (scope, translations, retries = 3) ->
      if @translationTable?
        keys = _.keys(translations)
        values = _.map _.toArray(translations), (translateKey) ->
          $translate.instant(translateKey)
        scope.translations = _.object keys, values
      else if retries > 0
        $timeout => @eagerTranslate(scope, translations, retries - 1)

    # ensure we've received a response from the url loader
    translationTable: ->
      @translationTable = @translationTable or $translate.getTranslationTable()

    listenForTranslations: (scope, context) ->
      context = context or scope
      scope.$on 'translationComplete', (e, translatedFields) =>
        return if e.defaultPrevented
        e.preventDefault()
        context.translation = translatedFields
