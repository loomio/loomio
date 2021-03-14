import {some, intersection, pick} from 'lodash'
export default new class RescueUnsavedEditsService
  constructor: ->
    @models = []

  okToLeave: ->
    attrs = ['description', 'title', 'body', 'details', 'name']
    if some(@models, (m) -> intersection(attrs, m.modifiedAttributes()).length > 0)
      console.log 'some modified', @models.map (m) ->
        modifiedAttrs = intersection(attrs, m.modifiedAttributes())
        o = {}
        o['new'] = pick(m, modifiedAttrs)
        o['old'] = pick(m.unmodified, modifiedAttrs)
        o
      confirm('are you sure?')
    else
      console.log 'none modified'
      @models = []
      true

  add: (model) ->
    console.log 'adding', model
    @models.push model

  clear: ->
    console.log 'clearing'
    @models = []
