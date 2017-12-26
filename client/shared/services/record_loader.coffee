Records = require 'shared/services/records.coffee'

_ = require 'lodash'

module.exports = class RecordLoader
  constructor: (opts = {}) ->
    @loadingFirst = true
    @collection = opts.collection
    @params     = _.merge({from: 0, per: 25, order: 'id'}, opts.params)
    @path       = opts.path
    @numLoaded  = opts.numLoaded or 0
    @then       = opts.then or (data) -> data

  reset: ->
    @params['from'] = 0
    @numLoaded  = 0

  fetchRecords: ->
    @loading = true
    Records[_.camelCase(@collection)].fetch
      path:   @path
      params: @params
    .then (data) =>
      records = data[@collection] || []
      @numLoaded += records.length
      @exhausted = true if records.length < @params.per
      data
    .then(@then)
    .finally =>
      @loadingFirst = false
      @loading = false

  loadMore: (from) ->
    if from?
      @params['from'] = from
    else
      @params['from'] += @params['per'] if @numLoaded > 0
    @loadingMore = true
    @fetchRecords().finally => @loadingMore = false

  loadPrevious: (from) ->
    if from?
      @params['from'] = from
    else
      @params['from'] -= @params['per'] if @numLoaded > 0
    @loadingPrevious = true
    @fetchRecords().finally => @loadingPrevious = false
