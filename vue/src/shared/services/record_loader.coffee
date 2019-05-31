import Records from '@/shared/services/records'

export default class RecordLoader
  constructor: (opts = {}) ->
    @loadingFirst = true
    @loading = false
    @loadingMore = false
    @loadingPrevious = false
    @collection   = opts.collection
    @params       = _.merge({from: 0, per: 25, order: 'id'}, opts.params)
    @path         = opts.path
    @numLoaded    = opts.numLoaded or 0
    @numRequested = opts.numRequested or @params['per']
    @then         = opts.then or (data) -> data
    @loading      = false

  reset: ->
    @params['from'] = 0
    @numLoaded  = 0

  fetchRecords: (opts = {}) ->
    @loading = true
    Records[_.camelCase(@collection)].fetch
      path:   @path
      params: _.defaults({}, opts, @params)
    .then (data) =>
      records = data[@collection] || []
      @numLoaded += records.length
      @numRequested += (opts.per || @params.per)
      @exhausted = true if records.length < (opts.per || @params.per)
      data
    .then(@then)
    .finally =>
      @loadingFirst = false
      @loadingPrevious = false
      @loading = false

  loadMore: (from) ->
    @params['from'] = from || @numLoaded
    @loadingMore = true
    @fetchRecords().finally => @loadingMore = false

  loadPrevious: (from) ->
    if from?
      @params['from'] = from
    else
      @params['from'] -= @params['per'] if @numLoaded > 0
    @loadingPrevious = true
    @fetchRecords()
