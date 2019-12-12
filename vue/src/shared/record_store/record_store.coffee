import RecordView from '@/shared/record_store/record_view'
import { snakeCase, isEmpty, camelCase, map, keys, each, intersection } from 'lodash'

export default class RecordStore
  constructor: (db) ->
    @db = db
    @collectionNames = []
    @views = {}

  addRecordsInterface: (recordsInterfaceClass) ->
    recordsInterface = new recordsInterfaceClass(@)
    recordsInterface.setRemoteCallbacks(@defaultRemoteCallbacks())
    name = camelCase(recordsInterface.model.plural)
    @[name] = recordsInterface
    recordsInterface.onInterfaceAdded()
    @collectionNames.push name

  import: (data) ->
    return if isEmpty(data)
    each @collectionNames, (name) =>
      snakeName = snakeCase(name)
      camelName = camelCase(name)
      if data[snakeName]?
        each data[snakeName], (recordData) =>
          @[camelName].importJSON(recordData)
          true

    @afterImport(data)

    each @views, (view) =>
      if intersection(view.collectionNames, map(keys(data), camelCase))
        view.query(@)
      true
    data

  afterImport: (data) ->

  setRemoteCallbacks: (callbacks) ->
    each @collectionNames, (name) => @[camelCase(name)].setRemoteCallbacks(callbacks)

  defaultRemoteCallbacks: ->
    onUploadSuccess: (data) => @import(data)
    onSuccess: (response) =>
      if response.ok
        response.json().then (data) =>
          @import(data)
      else
        throw response
    onFailure: (response) =>
      throw response if response.status != 403

  view: ({name, collections, query}) ->
    if !@views[name]
      @views[name] = new RecordView(name: name, recordStore: @, collections: collections, query: query)
    @views[name].query(@)
    @views[name]
