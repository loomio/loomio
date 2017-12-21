angular.module('loomioApp').factory 'TranslationService', ($translate, Session, Records) ->
  new class TranslationService

    # this sucks atm, but I want to improve and reintroduce it.
    # set the 'translations' value on scope to a hash with translated values
    # eagerTranslate: (scope, translations, retries = 3) ->
    #   if @translationTable?
    #     keys = _.keys(translations)
    #     values = _.map _.toArray(translations), (translateKey) ->
    #       $translate.instant(translateKey)
    #     scope.translations = _.object keys, values
    #   else if retries > 0
    #     $timeout => @eagerTranslate(scope, translations, retries - 1)

    listenForTranslations: (scope) ->
      scope.$on 'translationComplete', (e, translatedFields) =>
        return if e.defaultPrevented
        e.preventDefault()
        scope.translation = translatedFields

    inline: (scope, model) ->
      Records.translations.fetchTranslation(model, Session.user().locale).then (data) ->
        scope.translated = true
        scope.$emit 'translationComplete', data.translations[0].fields
