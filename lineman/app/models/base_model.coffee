angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'
    errors: {}
    processing: false

    constructor: (recordsInterface, data) ->
      Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: true)
      Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: true)
      Object.defineProperty(@, 'restfulClient', value: recordsInterface.restfulClient, enumerable: true)
      @initialize(data)
      @setupViews() if @setupViews? and @id?

    initialize: ->

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
