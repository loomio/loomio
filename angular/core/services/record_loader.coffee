angular.module('loomioApp').factory 'RecordLoader', (Records) ->
  class RecordLoader
    constructor: (opts = {}) ->
      @collection = opts.collection
      @params     = opts.params or {}
      @path       = opts.path
      @from       = opts.from or 0
      @per        = opts.per or 25
      @numLoaded  = opts.numLoaded or 0
      @then       = opts.then or ->

    reset: ->
      @from       = 0
      @numLoaded  = 0

    fetchRecords: ->
      @loading = true
      Records[_.camelCase(@collection)].fetch
        path:   @path
        params: _.merge(@params, { from: @from, per: @per })
      .then (data) =>
        if data[@collection].length > 0
          @numLoaded += data[@collection].length
        else
          @exhausted = true
        data
      .then(@then)
      .finally =>
        @loading = false

    loadFrom: (from) ->
      @from = from
      @fetchRecords()

    loadMore: ->
      @from += @per if @numLoaded > 0
      @fetchRecords()

    loadPrevious: ->
      @from -= @per if @numLoaded > 0
      @fetchRecords()
