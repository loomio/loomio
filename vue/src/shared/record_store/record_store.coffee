import RecordView from '@/shared/record_store/record_view'
import RestfulClient from './restful_client'
import utils         from '@/shared/record_store/utils'
import { snakeCase, isEmpty, camelCase, map, keys, each, intersection, merge, pick } from 'lodash'

export default class RecordStore
  constructor: (db) ->
    @db = db
    @collectionNames = []
    @views = {}

  remote: ->
    client = new RestfulClient
    client.onSuccess = (data) =>
      @importJSON(data)
      data
    client

  fetch: (args) ->
    @remote().fetch(args)

  addRecordsInterface: (recordsInterfaceClass) ->
    recordsInterface = new recordsInterfaceClass(@)
    name = camelCase(recordsInterface.model.plural)
    @[name] = recordsInterface
    @collectionNames.push name

  importJSON: (json) ->
    collections = pick(json, map(@collectionNames, snakeCase).concat(['parent_groups', 'parent_events']))
    @importREADY(utils.deserialize(collections))

  importREADY: (data) ->
    return [] if isEmpty(data)

    # hack just to get around AMS
    if data['parentGroups']?
      each data['parentGroups'], (recordData) =>
        @groups.importRecord(recordData)
        true

    if data['parentEvents']?
      each data['parentEvents'], (recordData) =>
        @events.importRecord(recordData)
        true

    each @collectionNames, (name) =>
      if data[name]?
        each data[name], (recordData) =>
          @[name].importRecord(recordData)
          true

    each @views, (view) =>
      if intersection( map(view.collectionNames, camelCase) , map(keys(data), camelCase) )
        view.query(@)
      true
    data

  view: ({name, collections, query}) ->
    if !@views[name]
      @views[name] = new RecordView(name: name, recordStore: @, collections: collections, query: query)
    @views[name].query(@)
    @views[name]
