angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'

    constructor: (recordsInterface, data) ->
      Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: true)
      Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: true)
      Object.defineProperty(@, 'restfulClient', value: recordsInterface.restfulClient, enumerable: true)
      @initialize(data)
      @setupViews() if @setupViews? and @id?

    initialize: ->

    setupViews: ->

    viewName: -> "#{@constructor.plural}#{@id}"

    isNew: ->
      not @id?

    keyOrId: ->
      if @key?
        @key
      else
        @id

    save: ->
      if @isNew()
        @restfulClient.create(@serialize())
      else
        @restfulClient.update(@keyOrId(), @serialize())

    destroy: ->
      @restfulClient.destroy(@keyOrId())

    update: (record) ->
      @restfulClient.update(@keyOrId(), @serialize())
