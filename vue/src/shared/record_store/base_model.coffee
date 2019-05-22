import utils from './utils'
import Vue from 'vue'

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
    @update(@defaultValues())
    @update(attributes)
    @buildRelationships() if @relationships?
    @afterConstruction()

  bumpVersion: ->
    @_version = @_version + 1

  afterConstruction: ->

  defaultValues: ->
    {}

  clone: ->
    cloneAttributes = {}
    _.forEach @attributeNames, (attr) =>
      if _.isArray(@[attr])
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
    @attributeNames = _.union(@attributeNames, _.keys(attributes))
    _.forEach(attributes, (value, key) =>
      Vue.set(@, key, value)
      return true
    )

    @recordsInterface.collection.update(@) if @inCollection()

  attributeIsModified: (attributeName) ->
    return false unless @clonedFrom?
    original = @clonedFrom[attributeName]
    current = @[attributeName]
    if utils.isTimeAttribute(attributeName)
      !(original == current or current.isSame(original))
    else
      original != current

  modifiedAttributes: ->
    return [] unless @clonedFrom?
    _.filter @attributeNames, (name) =>
      @attributeIsModified(name)

  isModified: ->
    return false unless @clonedFrom?
    @modifiedAttributes().length > 0

  serialize: ->
    @baseSerialize()

  baseSerialize: ->
    wrapper = {}
    data = {}
    paramKey = _.snakeCase(@constructor.serializationRoot or @constructor.singular)

    _.each @constructor.serializableAttributes or @attributeNames, (attributeName) =>
      snakeName = _.snakeCase(attributeName)
      camelName = _.camelCase(attributeName)
      if utils.isTimeAttribute(camelName)
        data[snakeName] = @[camelName].utc().format()
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
    args = _.defaults userArgs,
      from: name
      with:  @constructor.singular+'Id'
      of: 'id'
      dynamicView: true

    @[name] = => @recordStore[args.from].find("#{args.with}": @[args.of])

  belongsTo: (name, userArgs) ->
    defaults =
      from: name+'s'
      by: name+'Id'

    args = _.assign defaults, userArgs

    @[name] = => @recordStore[args.from].find(@[args.by])

  translationOptions: ->

  isA: (models...) ->
    _.includes models, @constructor.singular

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
    @remote.destroy(@keyOrId()).then =>
      @processing = false

  beforeDestroy: =>

  beforeRemove: =>

  save: =>
    @processing = true

    if @isNew()
      @remote.create(@serialize()).then(@afterSave)
    else
      @remote.update(@keyOrId(), @serialize()).then(@afterSave)

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
    @errors = {}
    _.each errorList, (errors, key) =>
      @errors[_.camelCase(key)] = errors

  isValid: ->
    @errors.length > 0
