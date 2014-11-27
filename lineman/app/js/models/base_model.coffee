angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
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

