module.exports = new class HasDrafts
  apply: (model) ->
    model.draftParent = model.draftParent or ->
      model[model.constructor.draftParent]()

    model.draft = ->
      return unless parent = model.draftParent()
      model.recordStore.drafts.findOrBuildFor(parent)

    model.fetchDraft = ->
      return unless parent = model.draftParent()
      model.recordStore.drafts.fetchFor(parent)

    model.restoreDraft = ->
      return unless draft = model.draft()
      payloadField = _.snakeCase(model.constructor.serializationRoot or model.constructor.singular)
      model.update _.omit(draft.payload[payloadField], _.isNull)

    model.resetDraft = ->
      return unless draft = model.draft()
      draft.updateFrom(model.recordStore[model.constructor.plural].build())

    model.updateDraft = ->
      return unless draft = model.draft()
      draft.updateFrom(model)
