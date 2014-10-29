angular.module('loomioApp').factory 'UserAuthService', (RecordStoreService, UserModel, $http) ->
  new class UserAuthService
    constructor: ->
      @currentUser = null

    fetchCurrentUser: ->
      $http.get('/api/v1/sessions/current').then (response) =>
        user = new UserModel(response.data.user)
        RecordStoreService.put(user)
        @currentUser = user
