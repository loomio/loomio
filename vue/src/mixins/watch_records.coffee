import Records from '@/shared/services/records'

export default
  data: ->
    watchedRecords: []

  methods:
    watchRecords: ({collections, query, key = ''}) ->
      name = "#{collections.join('_')}_#{@_uid}_#{key}"
      @watchedRecords.push name
      Records.view
        name: name
        collections: collections
        query: query

  beforeDestroy: ->
    @watchedRecords.forEach (name) -> delete Records.views[name]
