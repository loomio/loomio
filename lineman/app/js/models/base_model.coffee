angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    constructor: (recordStore, data) ->
      Object.defineProperty(@, 'recordStore', value: recordStore, enumerable: false)
      @initialize(data)
      @setupViews() if @setupViews?
      recordStore[@constructor.plural].put @

    initialize: ->
    setupViews: ->

    viewName: -> "#{@constructor.plural}#{@id}"

    isNew: ->
      not @id?

