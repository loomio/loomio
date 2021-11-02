import RestfulClient from './restful_client'
import utils         from '@/shared/record_store/utils'
import {pick, each, merge, keys, isNumber, isString, isArray, debounce, difference, uniq} from 'lodash'
import Vue           from 'vue'

export default class BaseRecordsInterface
  views: []
  model: 'undefinedModel'

  missingIds: []
  fetchedIds: []

  fetchMissing: debounce ->
    xids = difference(@missingIds, @fetchedIds).join('x')
    return if xids.length == 0

    @fetch
      path: ''
      params:
        xids: xids

    @fetchedIds = uniq @fetchedIds.concat(@missingIds)
    @missingIds = []
  , 500

  addMissing: (id) ->
    @missingIds.push(id)
    @fetchMissing()

  fetchAnyMissingById: (allIds) ->
    presentIds = @collection.chain().find(id: {$in: allIds}).data().map((r) -> r.id)
    @missingIds = uniq @missingIds.concat(difference(allIds, presentIds))
    @fetchMissing()

  nullModel: -> null
  # override this if your apiEndPoint is not the model.plural
  apiEndPoint: null

  constructor: (recordStore) ->
    @baseConstructor recordStore

  baseConstructor: (recordStore) ->
    @recordStore = recordStore
    @collection = @recordStore.db.addCollection(@collectionName or @model.plural, {indices: @model.indices})
    each @model.uniqueIndices, (name) =>
      @collection.ensureUniqueIndex(name)

    @remote = new RestfulClient(@apiEndPoint or @model.plural)

    @remote.onSuccess = (data) =>
      @recordStore.importJSON(data)
      data

    @remote.onUploadSuccess = (data) =>
      @recordStore.importJSON(data)
      data

  all: ->
    @collection.data

  build: (attributes = {}) ->
    record = new @model @, attributes
    Vue.observable(record)

  create: (attributes = {}) ->
    record = @build(attributes)
    @collection.insert(record)
    record

  fetch: (args) ->
    @remote.fetch(args)

  importRecord: (attributes) ->
    record = @find(attributes.key) if attributes.key?
    record = @find(attributes.id) if attributes.id? and !record?
    if record
      record.update(attributes)
    else
      record = @create(attributes)
    record

  findOrFetchById: (id, params = {}) ->
    record = @find(id)
    if record
      @remote.fetchById(id, params)
      Promise.resolve(record)
    else
      @remote.fetchById(id, params).then (data) =>
        @find(id)

  find: (q) ->
    if q == null or q == undefined
      undefined
    else if isNumber(q)
      @findById(q)
    else if isString(q)
      @findByKey(q)
    else if isArray(q)
      if q.length == 0
        []
      else if isString(q[0])
        @findByKeys(q)
      else if isNumber(q[0])
        @findByIds(q)
    else
      chain = @collection.chain()
      each keys(q), (key) ->
        chain.find("#{key}": q[key])
        true
      chain.data()

  findOrNull: (q) ->
    res = @find(q)
    if isArray(res) and res.length == 0
      null
    else
      res

  findById: (id) ->
    @collection.by('id', id)

  findByKey: (key) ->
    if @collection.constraints.unique['key']?
      @collection.by('key', key)
    else
      @collection.findOne(key: key)

  findByIds: (ids) ->
    @collection.find(id: {'$in': ids})

  findByKeys: (keys) ->
    @collection.find(key: {'$in': keys})
