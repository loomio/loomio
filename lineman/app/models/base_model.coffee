angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'
    @indices: []
    @attributeNames: []

    constructor: (recordsInterface, data) ->
      @errors = {}
      @processing = false
      Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: false)
      Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: false)
      Object.defineProperty(@, 'restfulClient', value: recordsInterface.restfulClient, enumerable: false)
      @initialize(data)
      @setupViews() if @setupViews? and @id?

    initialize: (data) ->
      @updateFromJSON(data)

    update: (data) ->
      @updateFromJSON(data)

    # copy rails snake_case hash, into camelCase object properties
    # also initialize attributes that end in _at or are listed as moments
    updateFromJSON: (data) ->
      @scrapeAttributeNames(data)
      @importData(data, @)

    scrapeAttributeNames: (data) ->
      @constructor.attributeNames = _.map _.keys(data), (key) -> _.camelCase(key)

    importData: (data, dest) ->
      _.each _.keys(data), (key) =>
        attributeName = _.camelCase(key)
        if /At$/.test(attributeName)
          dest[attributeName] = moment(data[key])
        else
          dest[attributeName] = data[key]
        return

    # copy camcelCase attributes to snake_case object for rails
    serialize: ->
      @baseSerialize()

    baseSerialize: ->
      data = {}
      _.each @attributeNames, (attributeName) ->
        data[_.snakeCase(attributeName)] = this[attributeName]
      data

    setupViews: ->

    translationOptions: ->

    viewName: -> "#{@constructor.plural}#{@id}"

    isNew: ->
      not @id?

    keyOrId: ->
      if @key?
        @key
      else
        @id

    save: ->
      @errors = {}
      @processing = true
      if @isNew()
        @restfulClient.create(@serialize()).then(@saveSuccess, @saveFailure)
      else
        @restfulClient.update(@keyOrId(), @serialize()).then(@saveSuccess, @saveFailure)

    destroy: ->
      @processing = true
      @restfulClient.destroy(@keyOrId()).then(@saveSuccess, @saveFailure)

    saveSuccess: (records) ->
      @processing = false
      records

    saveFailure: (errors) ->
      @processing = false
      @errors = errors
      throw errors

    isValid: ->
      @errors.length > 0
