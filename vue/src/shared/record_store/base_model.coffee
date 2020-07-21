import utils from './utils'
import Vue from 'vue'
import { isEqual } from 'date-fns'
import { camelCase, union, each, isArray, keys, filter, snakeCase, defaults, orderBy, assign, includes } from 'lodash-es'

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
    cloneAttributes.cloney = true
    cloneRecord = new @constructor(@recordsInterface, cloneAttributes)
    cloneRecord.clonedFrom = @
    cloneRecord

  inCollection: =>
    @['$loki']# and @recordsInterface.collection.get(@['$loki'])

  update: (attributes) ->
    @baseUpdate(attributes)

  baseUpdate: (attributes) ->
    @bumpVersion()
    @attributeNames = union @attributeNames, keys(attributes)
    each attributes, (value, key) =>
      Vue.set(@, key, value)
      true

    @recordsInterface.collection.update(@) if @inCollection()

  attributeIsModified: (attributeName) ->
    return false unless @clonedFrom?
    original = @clonedFrom[attributeName]
    current = @[attributeName]
    if utils.isTimeAttribute(attributeName)
      !(original == current or isEqual(original, current))
    else
      original != current

  modifiedAttributes: ->
    return [] unless @clonedFrom?
    filter @attributeNames, (name) =>
      @attributeIsModified(name)

  isModified: ->
    return false unless @clonedFrom?
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
      if utils.isTimeAttribute(camelName)
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

    @[name] = =>
      if userArgs.orderBy
        orderBy @recordStore[args.from].find("#{args.with}": @[args.of]), userArgs.orderBy
      else
        @recordStore[args.from].find("#{args.with}": @[args.of])

  belongsTo: (name, userArgs) ->
    values =
      from: name + 's'
      by: name + 'Id'

    args = assign values, userArgs

    @[name] = => @recordStore[args.from].find(@[args.by])
    @[name+'Is'] = (obj) => @recordStore[args.from].find(@[args.by]) == obj

  translationOptions: ->

  isA: (models...) ->
    includes models, @constructor.singular

  namedId: ->
    { "#{@constructor.singular}_id": @id }

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
    @remote.destroy(@keyOrId()).finally =>
      @processing = false

  beforeDestroy: =>

  beforeRemove: =>

  discard: =>
    @processing = true
    @remote.discard(@keyOrId()).finally =>
      @processing = false

  undiscard: =>
    @processing = true
    @remote.undiscard(@keyOrId()).finally =>
      @processing = false

  save: =>
    @processing = true

    if @isNew()
      @remote.create(@serialize()).then(@afterSave).finally => @processing = false
    else
      @remote.update(@keyOrId(), @serialize()).then(@afterSave).finally => @processing = false

  afterSave: (data) =>
    @processing = false
    if data.errors
      @setErrors(data.errors)
      throw data
    else
      @clonedFrom = undefined
      data

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
