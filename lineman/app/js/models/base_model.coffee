angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @service: 'undefinedService'
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'

    constructor: (recordStore, data) ->
      Object.defineProperty(@, 'recordStore', value: recordStore, enumerable: false)
      @initialize(data)
      @setupViews() if @setupViews? and @id?
      #recordStore[@constructor.plural].insert @

    initialize: ->
    setupViews: ->

    viewName: -> "#{@constructor.plural}#{@id}"

    isNew: ->
      not @id?

    save: (s, f) ->
      @constructor.service.save(@, s, f)
