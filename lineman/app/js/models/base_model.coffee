angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    constructor: (recordStore, data) ->
      Object.defineProperty(@, 'recordStore', value: recordStore, enumerable: false)
      @initialize(data)
      @setupViews() if @setupViews? and @id?

    initialize: ->
    setupViews: ->

    viewName: -> "#{@constructor.plural}#{@id}"

    isNew: ->
      not @id?

    copy: =>
      cloner = ->
      cloner.prototype = @constructor.prototype 
      angular.extend new cloner(), _.clone(@), recordStore: @recordStore
