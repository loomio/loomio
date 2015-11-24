angular.module('loomioApp').factory 'DraftService', ->
  new class DraftService

    applyDrafting: (scope, model) ->
      draftMode = ->
        model[model.constructor.draftParent]() && model.isNew()

      scope.storeDraft = ->
        model.updateDraft() if draftMode()

      scope.restoreDraft = ->
        model.restoreDraft() if draftMode()
      scope.restoreDraft()

      scope.restoreRemoteDraft = ->
        model.fetchDraft().then(scope.restoreDraft) if draftMode()
