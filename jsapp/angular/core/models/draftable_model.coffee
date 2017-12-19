angular.module('loomioApp').factory 'DraftableModel', (BaseModel) ->
  class DraftableModel extends BaseModel
    @draftParent: 'undefined'

    draftParent: ->
      @[@constructor.draftParent]()

    draft: ->
      return unless parent = @draftParent()
      @recordStore.drafts.findOrBuildFor(parent)

    fetchDraft: =>
      return unless parent = @draftParent()
      @recordStore.drafts.fetchFor(parent)

    restoreDraft: ->
      return unless draft = @draft()
      payloadField = _.snakeCase(@constructor.serializationRoot or @constructor.singular)
      @update _.omit(draft.payload[payloadField], _.isNull)

    resetDraft: ->
      return unless draft = @draft()
      draft.updateFrom(@recordStore[@constructor.plural].build())

    updateDraft: ->
      return unless draft = @draft()
      draft.updateFrom(@)
