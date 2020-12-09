import Records from '@/shared/services/records'
import {merge, camelCase, defaults, max } from 'lodash'

export default class RecordLoader
  constructor: (opts = {}) ->
    @exhausted = false
    @loading = false
    @collection   = opts.collection
    @params       = merge({from: 0, per: 25, order: 'id'}, opts.params)
    @path         = opts.path
    # @numLoaded    = opts.numLoaded or 0
    @total        = 0
    @err = null
    @status = null

  reset: ->
    @params['from'] = 0
    # @numLoaded = 0

  fetchRecords: (opts = {}) ->
    @loading = true
    @params = defaults({}, opts, @params)
    Records[camelCase(@collection)].fetch
      path: @path
      params: @params
    .then (data) =>
      @total = data.meta.total
      @params.from = @params.from + @params.per
      @exhausted = @params.from >= @total
      data
    .finally =>
      @loading = false
    .catch (err) =>
      @err = err
      @status = err.status
