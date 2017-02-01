angular.module('loomioApp').factory 'RecordLoader', (Records) ->
  class RecordLoader
    constructor: (opts = {}) ->
      @collection = opts.collection
      @params     = opts.params or {}
      @from       = opts.from or 0
      @per        = opts.per or 25
      @numLoaded  = opts.numLoaded or 0

    fetchRecords: ->
      Records[_.camelCase(@collection)].fetch
        params: _.merge(@params, { from: @from, per: @per })
      .then (data) =>
        @numLoaded += data[@collection].length

    loadMore: ->
      @from += @per
      @fetchRecords()
