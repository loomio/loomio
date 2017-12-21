angular.module('loomioApp').factory 'DraftService', ($timeout, AppConfig) ->
  new class DraftService

    applyDrafting: (scope, model) ->
      draftMode = ->
        model[model.constructor.draftParent]() && model.isNew()

      timeout = $timeout(->)
      scope.$watch ->
        _.pick(model, model.constructor.draftPayloadAttributes)
      , ->
        return unless draftMode()
        $timeout.cancel(timeout)
        timeout = $timeout((-> model.updateDraft()), AppConfig.drafts.debounce)
      , true

      scope.restoreDraft = ->
        model.restoreDraft() if draftMode()

      scope.restoreRemoteDraft = ->
        model.fetchDraft().then(scope.restoreDraft) if draftMode()
      scope.restoreRemoteDraft()
