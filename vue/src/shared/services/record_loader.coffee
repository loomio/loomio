import Records from '@/shared/services/records'
import {merge, camelCase, defaults, max } from 'lodash'

export default class RecordLoader
  constructor: (opts = {}) ->
    @exhausted = false
    @loadingFirst = true
    @loading = false
    @loadingMore = false
    @loadingPrevious = false
    @collection   = opts.collection
    @params       = merge({from: 0, per: 25, order: 'id'}, opts.params)
    @path         = opts.path
    @numLoaded    = opts.numLoaded or 0
    @then         = opts.then or (data) -> data
    @loading      = false
    @status = null

  reset: ->
    @params['from'] = 0
    @numLoaded = 0

  limit: ->
    @params.from + @params.per

  fetchRecords: (opts = {}) ->
    @loading = true
    @exhausted = false
    Records[camelCase(@collection)].fetch
      path: @path
      params: defaults({}, opts, @params)
    .then (data) =>
      records = data[@collection] || []
      @params.from = @params.from + @params.per
      @numLoaded += records.length
      @exhausted = true if records.length < (opts.per || @params.per)
      data
    .then(@then)
    .catch (err) =>
      @status = err.status
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
      @params['from'] = max([1, @params['from'] - @params['per']])

    @loadingPrevious = true
    @fetchRecords()
