angular.module('loomioApp').factory 'RecordLoader', (Records) ->
  class RecordLoader
    constructor: (opts = {}) ->
      @loadingFirst = true
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
        @loadingFirst = false
        @loading = false

    loadMore: (from) ->
      if from?
        @from = from
      else
        @from += @per if @numLoaded > 0
      @loadingMore = true
      @fetchRecords().finally => @loadingMore = false

    loadPrevious: (from) ->
      if from?
        @from = from
      else
        @from -= @per if @numLoaded > 0
      @loadingPrevious = true
      @fetchRecords().finally => @loadingPrevious = false
