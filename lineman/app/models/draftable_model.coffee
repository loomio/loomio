angular.module('loomioApp').factory 'DraftableModel', (BaseModel) ->
  class DraftableModel extends BaseModel
    @draftParent: 'undefined'

    draft: ->
      @recordStore.drafts.findOrBuildFor(@[@constructor.draftParent]())

    fetchDraft: =>
      @recordStore.drafts.fetchFor(@[@constructor.draftParent]())

    restoreDraft: ->
      @update @draft().payload[@constructor.singular]

    resetDraft: ->
      @draft().updateFrom(@recordStore[@constructor.plural].build())

    updateDraft: ->
      @draft().updateFrom(@)
