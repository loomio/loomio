angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'
    @indices: []
    @attributeNames: []
    @searchableFields: []

    constructor: (recordsInterface, data, postInitializeData = {}) ->
      @errors = {}
      @processing = false
      Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: false)
      Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: false)
      Object.defineProperty(@, 'restfulClient', value: recordsInterface.restfulClient, enumerable: false)
      @initialize(data)
      _.merge @, postInitializeData
      @setupViews() if @setupViews? and @id?

    defaultValues: ->
      {}

    initialize: (data) ->
      @baseInitialize(data)

    baseInitialize: (data) ->
      @updateFromJSON(@defaultValues())
      @updateFromJSON(data)

    clone: ->
      attrs = @baseSerialize()[@constructor.singular] or {}
      new @constructor @recordsInterface, attrs, { id: @id, key: @key }

    update: (data) ->
      @updateFromJSON(data)

    # copy rails snake_case hash, into camelCase object properties
    # also initialize attributes that end in _at or are listed as moments
    updateFromJSON: (data) ->
      @scrapeAttributeNames(data)
      @importData(data, @)

    scrapeAttributeNames: (data) ->
      _.each _.keys(data), (key) =>
        camelKey = _.camelCase(key)
        unless _.contains @constructor.attributeNames, camelKey
          @constructor.attributeNames.push camelKey

    importData: (data, dest) ->
      _.each _.keys(data), (key) =>
        attributeName = _.camelCase(key)
        if /At$/.test(attributeName)
          if moment(data[key]).isValid()
            dest[attributeName] = moment(data[key])
          else
            dest[attributeName] = null
        else
          dest[attributeName] = data[key]
        return

    # copy camcelCase attributes to snake_case object for rails
    serialize: ->
      @baseSerialize()

    baseSerialize: ->
      wrapper = {}
      data = {}
      paramKey = _.snakeCase(@constructor.singular)
      _.each window.Loomio.permittedParams[paramKey], (attributeName) =>
        data[_.snakeCase(attributeName)] = @[_.camelCase(attributeName)]
        true # so if the value is false we don't break the loop
      wrapper[paramKey] = data
      wrapper

    addView: (collectionName, viewName) ->
      @recordStore[collectionName].collection.addDynamicView("#{@id}-#{viewName}")

    setupViews: ->

    setupView: (view, sort, desc) ->
      viewName = "#{view}View"
      idOption = {}
      idOption["#{@constructor.singular}Id"] = @id

      @[viewName] = @recordStore[view].collection.addDynamicView(@viewName())
      @[viewName].applyFind(idOption)
      @[viewName].applyFind(id: {$gt: 0})
      @[viewName].applySimpleSort(sort or 'createdAt', desc)

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
      if @processing
        console.log "save returned, already processing:", @
        return

      @processing = true
      if @isNew()
        @restfulClient.create(@serialize()).then(@saveSuccess, @saveFailure)
      else
        @restfulClient.update(@keyOrId(), @serialize()).then(@saveSuccess, @saveFailure)

    destroy: ->
      @processing = true
      @restfulClient.destroy(@keyOrId()).then =>
        @processing = false
        @recordsInterface.remove(@)
      , ->

    saveSuccess: (records) =>
      @processing = false
      records

    saveFailure: (errors) =>
      @processing = false
      @errors = errors
      throw errors

    isValid: ->
      @errors.length > 0
