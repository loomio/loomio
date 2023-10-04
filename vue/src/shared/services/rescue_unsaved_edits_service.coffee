import {some, intersection, pick, uniq} from 'lodash'
import I18n from '@/i18n'

export default new class RescueUnsavedEditsService
  constructor: ->
    @models = []

  okToLeave: (model) ->
    attrs = [
      'description',
      'title',
      'body',
      'details',
      'name',
      'reason',
      'statement',
      'titlePlaceholder',
      'processIntroduction',
      'processName',
      'processSubtitle'
    ]
    models = uniq ((model && [model]) || @models).flat()
    models.forEach (m) -> 
      m.beforeSaves.forEach (f) -> f()
    if some(models, (m) -> intersection(attrs, m.modifiedAttributes()).length > 0)
      # console.log 'some modified', @models.map (m) ->
      #   modifiedAttrs = intersection(attrs, m.modifiedAttributes())
      #   if modifiedAttrs.length > 0
      #     o = {}
      #     o['new'] = pick(m, modifiedAttrs)
      #     o['old'] = pick(m.unmodified, modifiedAttrs)
      #     o
      #   else
      #     null

      ms = uniq(@models.map (m) -> m.constructor.singular)
      as = uniq((@models.map (m) -> intersection(attrs, m.modifiedAttributes())).flat().flat())

      # if confirm("#{ms.join(' ') } #{as.join(' ')} #{models[0][as[0]]}")
      if confirm(I18n.t('common.confirm_discard_changes'))
        (model && model.discardChanges()) || true
      else
        false
    else
      @models = []
      true

  add: (model) ->
    @models.push model

  clear: ->
    @models = []
