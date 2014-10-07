angular.module('loomioApp').factory 'UserModel', (RecordStoreService) ->
  class UserModel
    constructor: (data = {}) ->
      @id = data.id
      @name = data.name

    plural: 'users'
