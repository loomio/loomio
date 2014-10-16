angular.module('loomioApp').factory 'GroupModel', (RecordStoreService) ->
  class GroupModel
    constructor: (data = {}) ->
      @id = data.id
      @key = data.key
      @name = data.name
      @description = data.description
      @parentId = data.parent_id
      @createdAt = data.created_at

    plural: 'groups'

    fullName: (separator = '>') ->
      if @parentId?
        "#{@parent().name} #{separator} #{@name}"
      else
        @name

    parent: ->
      RecordStoreService.get('groups', @parentId)
