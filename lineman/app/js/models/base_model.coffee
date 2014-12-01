angular.module('loomioApp').factory 'BaseModel', ->
  class BaseModel
    @singular: 'undefinedSingular'
    @plural: 'undefinedPlural'

    constructor: (recordsInterface, data) ->
      Object.defineProperty(@, 'recordsInterface', value: recordsInterface, enumerable: false)
      Object.defineProperty(@, 'recordStore', value: recordsInterface.recordStore, enumerable: false)
      @initialize(data)
      @setupViews() if @setupViews? and @id?

    initialize: ->

    setupViews: ->

    viewName: -> "#{@constructor.plural}#{@id}"

    isNew: ->
      not @id?

    save: (s, f) ->
      @recordsInterface.save(@, s, f)

    copy: =>
      cloner = ->
      cloner.prototype = @constructor.prototype
      angular.extend new cloner(), _.clone(@), recordStore: @recordStore
