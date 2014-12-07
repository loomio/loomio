angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'

    constructor: (recordsInterface, data) ->
      Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: false)
      Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: false)
      Object.defineProperty(@, 'restfulClient', value: recordsInterface.restfulClient, enumerable: false)
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

    copy: =>
      cloner = ->
      cloner.prototype = @constructor.prototype
      angular.extend new cloner(), _.clone(@), recordStore: @recordStore
