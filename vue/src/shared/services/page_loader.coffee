import Records from '@/shared/services/records'
import utils         from '@/shared/record_store/utils'
import RestfulClient from '@/shared/record_store/restful_client'
import Vue from 'vue'
import {merge, camelCase, defaults, max, orderBy, uniq, map } from 'lodash'

export default class PageLoader
  constructor: (opts) ->
    @remote = new RestfulClient
    @loading = false
    @params = opts.params
    @path = opts.path
    @per = opts.params.per
    @order = opts.order
    @total = 0
    @pageWindow = {}
    @err = null
    @status = null

  totalPages: ->
    Math.ceil(parseFloat(@total) / parseFloat(@params.per))

  fetch: (page) ->
    @loading = true
    @remote.fetch
      path: @path
      params: merge({from: ((page - 1) * @per)}, @params)
    .then (json) =>
      data = utils.deserialize(json)
      @total = data.meta.total
      firstId = data[data.meta.root][0][@order]
      lastId = data[data.meta.root][(data[data.meta.root].length - 1)][@order]
      Vue.set(@pageWindow, page, [lastId,firstId])
      # console.log 'page', page, 'discussions.length', data.discussions.length, 'first', firstId, 'last', lastId, 'groupIds!', orderBy uniq(map(data['discussions'], 'groupId'))
      Records.importREADY(data)
    .catch (err) =>
      @err = err
      @status = err.status
    .finally =>
      @loading = false
