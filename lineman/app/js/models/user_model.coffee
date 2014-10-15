angular.module('loomioApp').factory 'UserModel', (RecordStoreService) ->
  class UserModel
    constructor: (data = {}) ->
      @id = data.id
      @name = data.name
      @avatar_url = data.avatar_url
      @avatar_initials = data.avatar_initials


    avatar_or_initials: ->
      @avatar_url or @avatar_initials

    plural: 'users'
