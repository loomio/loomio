angular.module('loomioApp').factory 'DraftableModel', (BaseModel) ->
  class DraftableModel extends BaseModel
    @draftParent: 'undefined'

    draft: ->
      @recordStore.drafts.findOrBuildFor(@[@constructor.draftParent]())

    fetchDraft: =>
      @recordStore.drafts.fetchFor(@[@constructor.draftParent]())

    restoreDraft: ->
      payloadField = _.snakeCase(@constructor.serializationRoot or @constructor.singular)
      @update _.omit(@draft().payload[payloadField], _.isNull)

    resetDraft: ->
      @draft().updateFrom(@recordStore[@constructor.plural].build())

    updateDraft: ->
      @draft().updateFrom(@)
