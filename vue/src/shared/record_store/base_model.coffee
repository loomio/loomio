import utils from './utils'
import Vue from 'vue'
import { isEqual } from 'date-fns'
import { camelCase, union, each, isArray, keys, filter, snakeCase, defaults, orderBy, assign, includes, pick } from 'lodash'

export default class BaseModel
  @singular: 'undefinedSingular'
  @plural: 'undefinedPlural'

  # indicate to Loki our 'primary keys' - it promises to make these fast to lookup by.
  @uniqueIndices: ['id']

  # list of other attributes to index
  @indices: []

  @searchableFields: []

  # whitelist of attributes to include when serializing the record.
  # leave null to serialize all attributes
  @serializableAttributes: null

  # what is the key to use when serializing the record?
  @serializationRoot: null

  constructor: (recordsInterface, attributes = {}) ->
    @processing = false # not returning/throwing on already processing rn
    @_version = 0
    @attributeNames = []
    @unmodified = {}
    @setErrors()
    Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: false)
    Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: false)
    Object.defineProperty(@, 'remote', value: recordsInterface.remote, enumerable: false)
    @buildRelationships() if @relationships?
    @update(@defaultValues())
    @update(attributes)
    @afterConstruction()

  bumpVersion: ->
    @_version = @_version + 1

  afterConstruction: ->

  defaultValues: -> {}

  clone: ->
    cloneAttributes = {}
    each @attributeNames, (attr) =>
      if isArray(@[attr])
        cloneAttributes[attr] = @[attr].slice(0)
      else
        cloneAttributes[attr] = @[attr]
      true
    new @constructor(@recordsInterface, cloneAttributes)

  inCollection: =>
    @['$loki']

  update: (attributes) ->
    @baseUpdate(attributes)

  baseUpdate: (attributes) ->
    @bumpVersion()
    @attributeNames = union @attributeNames, keys(attributes)
    each attributes, (value, key) =>
      @unmodified[key] = value
      Vue.set(@, key, value)
      true

    @recordsInterface.collection.update(@) if @inCollection()

  attributeIsModified: (attributeName) ->
    original = @unmodified[attributeName]
    current = @[attributeName]
    if utils.isTimeAttribute(attributeName)
      !(original == current or isEqual(original, current))
    else
      original != current

  modifiedAttributes: ->
    filter @attributeNames, (name) =>
      @attributeIsModified(name)

  isModified: ->
    @modifiedAttributes().length > 0

  serialize: ->
    @baseSerialize()

  baseSerialize: ->
    wrapper = {}
    data = {}
    paramKey = snakeCase(@constructor.serializationRoot or @constructor.singular)

    each @constructor.serializableAttributes or @attributeNames, (attributeName) =>
      snakeName = snakeCase(attributeName)
      camelName = camelCase(attributeName)
      if utils.isTimeAttribute(camelName) and @[camelName]
        data[snakeName] = @[camelName].toISOString()
      else
        data[snakeName] = @[camelName]
      true # so if the value is false we don't break the loop

    wrapper[paramKey] = data
    wrapper

  relationships: ->

  buildRelationships: ->
    @views = {}
    @relationships()

  hasMany: (name, userArgs = {}) ->
    args = defaults userArgs,
      from: name
      with: @constructor.singular + 'Id'
      of: 'id'
      find: {}

    @[name] = =>
      find = Object.assign({}, {"#{args.with}": @[args.of]},  args.find)
      if userArgs.orderBy
        orderBy @recordStore[args.from].find(find), userArgs.orderBy
      else
        @recordStore[args.from].find(find)

  belongsTo: (name, userArgs) ->
    values =
      from: name + 's'
      by: name + 'Id'

    args = assign values, userArgs

    @[name] = =>
      if @[args.by]
        return obj if obj = @recordStore[args.from].find(@[args.by])
        obj = @recordStore[args.from].create(id: @[args.by])
        @recordStore[args.from].addMissing(@[args.by])
        return obj
      return @recordStore[args.from].nullModel()
    @[name+'Is'] = (obj) => @recordStore[args.from].find(@[args.by]) == obj

  translationOptions: ->

  isA: (models...) ->
    includes models, @constructor.singular

  namedId: ->
    { "#{@constructor.singular}_id": @id }

  bestNamedId: ->
    @namedId()

  isNew: ->
    not @id?

  keyOrId: ->
    if @key?
      @key
    else
      @id

  remove: =>
    @beforeRemove()
    if @inCollection()
      @recordsInterface.collection.remove(@)

  destroy: =>
    @processing = true
    @beforeDestroy()
    @remove()
    @remote.destroy(@keyOrId())
    .then (data) =>
      @recordStore.importJSON(data)
    .finally =>
      @processing = false

  beforeDestroy: =>

  beforeRemove: =>

  discard: =>
    @processing = true
    @remote.discard(@keyOrId())
    .then (data) =>
      @recordStore.importJSON(data)
    .finally =>
      @processing = false

  undiscard: =>
    @processing = true
    @remote.undiscard(@keyOrId())
    .then (data) =>
      @recordStore.importJSON(data)
    .finally =>
      @processing = false

  save: =>
    @processing = true
    if @isNew()
      @remote.create(@serialize())
      .then(@saveSuccess, @saveError)
      .finally => @processing = false
    else
      @remote.update(@keyOrId(), @serialize())
      .then(@saveSuccess, @saveError)
      .finally => @processing = false

  saveSuccess: (data) =>
    @recordStore.importJSON(data)
    @unmodified = pick(@, @attributeNames)
    data

  saveError: (data) =>
    @setErrors(data.errors) if data.errors
    throw data

  discardChanges: ->
    @attributeNames.forEach (key) =>
      Vue.set(@, key, @unmodified[key])

  clearErrors: ->
    @errors = {}

  setErrors: (errorList = []) ->
    Vue.set(@, 'errors', {})
    each errorList, (errors, key) =>
      Vue.set(@errors, camelCase(key), errors)

  isValid: ->
    @errors.length > 0

  edited: ->
    @versionsCount > 1
