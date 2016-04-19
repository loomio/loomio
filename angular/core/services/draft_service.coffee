angular.module('loomioApp').factory 'DraftService', ($timeout) ->
  new class DraftService

    applyDrafting: (scope, model, watchFields) ->
      draftMode = ->
        model[model.constructor.draftParent]() && model.isNew()

      if draftMode()
        timeout = $timeout(->)
        scope.$watch ->
          _.map watchFields, (field) -> model[field]
        , ->
          $timeout.cancel(timeout)
          timeout = $timeout((-> model.updateDraft()), 300)

      scope.restoreDraft = ->
        model.restoreDraft() if draftMode()

      scope.restoreRemoteDraft = ->
        model.fetchDraft().then(scope.restoreDraft) if draftMode()
      scope.restoreRemoteDraft()
