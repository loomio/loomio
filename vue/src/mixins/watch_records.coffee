import Records from '@/shared/services/records'
import { each } from 'lodash'

export default
  data: ->
    watchedRecords: []

  methods:
    watchRecords: ({collections, query, key = ''}) ->
      name = "#{collections.join('_')}_#{@_uid}_#{key}"
      console.log name
      @watchedRecords.push name
      Records.view
        name: name
        collections: collections
        query: query

  beforeDestroy: ->
    each @watchedRecords, (name) ->
      delete Records.views[name]
      true
